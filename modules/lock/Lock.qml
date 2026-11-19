pragma ComponentBehavior: Bound

import qs.services

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import QtQml

Scope {
    id: root

    required property Component barContent
    property url backgroundSource: ""
    property string _response: ""
    property bool _providedResponse: false
    property bool _secure: false
    property string _error: ""
    property int _failures: 0

    function _lock(): void {
        if (intent.requested)
            return;
        _error = "";
        _failures = 0;
        intent.requested = true;
        Qt.callLater(() => {
            if (!session.locked)
                intent.requested = false;
        });
    }

    function _submit(password: string): void {
        if (!session.secure || pam.active || _response.length > 0 || password.length === 0)
            return;

        _error = "";
        _response = password;
        _providedResponse = false;
        if (!pam.start())
            _failed(qsTr("Unable to authenticate. Try again."));
    }

    function _failed(message: string): void {
        _response = "";
        _providedResponse = false;
        _error = message;
        _failures++;
    }

    function _syncSecure(): void {
        _secure = session.secure;
    }

    Connections {
        target: UiState

        function onLockRequested(): void {
            root._lock();
        }
    }

    PersistentProperties {
        id: intent

        reloadableId: "mshell-session-lock"
        property bool requested: false
        onRequestedChanged: UiState.lockActive = requested
    }

    WlSessionLock {
        id: session

        locked: intent.requested
        // The restored Wayland lock may already be secure when this generation starts.
        Component.onCompleted: Qt.callLater(root._syncSecure)
        onSecureChanged: root._syncSecure()
        onLockedChanged: {
            if (!locked)
                intent.requested = false;
        }

        LockSurface {
            barContent: root.barContent
            backgroundSource: root.backgroundSource
            ready: root._secure && intent.requested
            authenticating: pam.active
            errorMessage: root._error
            failures: root._failures
            onUnlockRequested: password => root._submit(password)
        }
    }

    PamContext {
        id: pam

        config: "system-auth"

        onPamMessage: {
            if (responseRequired) {
                if (responseVisible || root._response.length === 0) {
                    abort();
                } else {
                    const password = root._response;
                    root._response = "";
                    root._providedResponse = true;
                    respond(password);
                }
            }
        }

        onCompleted: result => {
            if (result === PamResult.Success && root._providedResponse && session.secure) {
                root._response = "";
                root._providedResponse = false;
                intent.requested = false;
                root._syncSecure();
            } else if (session.locked) {
                root._failed(result === PamResult.Failed ? qsTr("Incorrect password. Try again.")
                                                         : qsTr("Unable to authenticate. Try again."));
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            UiState.lockRequested();
        }
    }
}

(function() {
    "use strict";

    var storagePrefix = 'wrd-sphinx-theme-sidebar-';
    var collapsedWidth = 32;

    function readStorage(key) {
        try {
            return window.localStorage.getItem(key);
        } catch (error) {
            return null;
        }
    }

    function writeStorage(key, value) {
        try {
            window.localStorage.setItem(key, value);
        } catch (error) {
            return;
        }
    }

    function isMobile() {
        return window.matchMedia('(max-width: 767px)').matches;
    }

    function initSidebarControls() {
        var content = document.getElementById('content-wrapper');
        if (!content || !content.parentElement) return;

        var row = content.parentElement;
        var sidebars = Array.prototype.filter.call(row.children, function(child) {
            if (child === content) return false;
            return child.id === 'sidebar-wrapper' ||
                child.id === 'sidebar-right' ||
                child.hasAttribute('data-theme-sidebar') ||
                Boolean(child.querySelector('.sidebar'));
        });
        if (!sidebars.length) return;

        row.classList.add('theme-sidebar-layout');
        if (row.parentElement) {
            row.parentElement.classList.add('theme-sidebar-layout-container');
        }

        var navigation = document.querySelector('#navbar-top ul.navbar-nav.navbar-right') ||
            document.querySelector('#navbar-top ul.nav');
        var settingsPanel = navigation ? navigation.querySelector('.theme-settings-panel') : null;
        if (navigation && !settingsPanel) {
            var menuItem = document.createElement('li');
            menuItem.className = 'theme-settings-menu';

            var details = document.createElement('details');
            var summary = document.createElement('summary');
            summary.textContent = 'Settings';
            details.appendChild(summary);

            settingsPanel = document.createElement('div');
            settingsPanel.className = 'theme-settings-panel';
            settingsPanel.setAttribute('role', 'group');
            settingsPanel.setAttribute('aria-label', 'Sidebar visibility');
            details.appendChild(settingsPanel);
            menuItem.appendChild(details);
            navigation.appendChild(menuItem);

            summary.addEventListener('keydown', function(event) {
                if (event.key === 'Escape') {
                    details.open = false;
                }
            });
        }

        var states = [];
        var contentIndex = Array.prototype.indexOf.call(row.children, content);

        sidebars.forEach(function(sidebar) {
            if (sidebar.querySelector('.theme-sidebar-resize-handle')) return;
            var sidebarIndex = Array.prototype.indexOf.call(row.children, sidebar);
            var side = sidebarIndex < contentIndex ? 'left' : 'right';
            var widthKey = storagePrefix + side + '-width';
            var openKey = storagePrefix + side + '-open';

            sidebar.setAttribute('data-theme-sidebar-position', side);
            sidebar.classList.remove('hidden-xs');
            if (!sidebar.id) sidebar.id = 'theme-sidebar-' + side;

            var sidebarContent = sidebar.querySelector('.sidebar');
            if (sidebarContent) sidebarContent.classList.remove('hidden-xs');

            var width = sidebar.getBoundingClientRect().width || row.clientWidth * 0.25;
            var storedWidth = parseFloat(readStorage(widthKey));
            if (isFinite(storedWidth) && storedWidth > 0) width = storedWidth;

            var state = {
                side: side,
                sidebar: sidebar,
                width: width,
                open: true,
                handle: null,
                toggleButton: null,
                drag: null,
                ignoreNextClick: false
            };

            var handle = document.createElement('button');
            handle.type = 'button';
            handle.className = 'theme-sidebar-resize-handle';
            handle.setAttribute('data-theme-sidebar-handle', side);
            handle.setAttribute('aria-controls', sidebar.id);
            handle.setAttribute('aria-label', 'Toggle ' + side + ' sidebar');
            handle.setAttribute('aria-expanded', 'true');
            handle.title = 'Drag to resize. Click to hide or show.';
            sidebar.appendChild(handle);
            state.handle = handle;

            var toggleButton;
            if (settingsPanel) {
                toggleButton = document.createElement('button');
                toggleButton.type = 'button';
                toggleButton.setAttribute('data-theme-sidebar-toggle', side);
                toggleButton.setAttribute('aria-controls', sidebar.id);
                settingsPanel.appendChild(toggleButton);
                state.toggleButton = toggleButton;
            }

            function setWidth(nextWidth, persist) {
                var maxWidth = Math.min(520, Math.max(180, row.clientWidth - 340));
                state.width = Math.max(180, Math.min(maxWidth, nextWidth));
                row.style.setProperty('--theme-' + side + '-sidebar-width', state.width + 'px');
                if (persist) writeStorage(widthKey, String(state.width));
            }

            function setOpen(open, persist) {
                state.open = open;
                sidebar.classList.toggle('theme-sidebar-collapsed', !open);
                sidebar.classList.toggle('theme-sidebar-mobile-open', open && isMobile());
                row.style.setProperty(
                    '--theme-' + side + '-sidebar-width',
                    open ? state.width + 'px' : collapsedWidth + 'px'
                );
                if (sidebarContent) sidebarContent.setAttribute('aria-hidden', String(!open));
                handle.setAttribute('aria-expanded', String(open));
                if (toggleButton) {
                    toggleButton.textContent = (open ? 'Hide ' : 'Show ') + side + ' sidebar';
                    toggleButton.setAttribute('aria-pressed', String(open));
                }
                if (persist) writeStorage(openKey, String(open));
            }

            state.setOpen = setOpen;
            state.setWidth = setWidth;
            states.push(state);

            var savedOpen = readStorage(openKey);
            setOpen(savedOpen === null ? !isMobile() : savedOpen === 'true', false);

            if (toggleButton) {
                toggleButton.addEventListener('click', function() {
                    setOpen(!state.open, true);
                });
            }

            handle.addEventListener('pointerdown', function(event) {
                if (isMobile()) return;
                if (typeof event.button === 'number' && event.button !== 0) return;
                event.preventDefault();
                state.drag = {
                    pointerId: event.pointerId,
                    startX: event.clientX,
                    startWidth: state.open ? state.width : collapsedWidth,
                    moved: false
                };
                if (handle.setPointerCapture) {
                    try {
                        handle.setPointerCapture(event.pointerId);
                    } catch (error) {}
                }
            });

            window.addEventListener('pointermove', function(event) {
                if (!state.drag || state.drag.pointerId !== event.pointerId) return;
                var delta = event.clientX - state.drag.startX;
                if (side === 'right') delta = -delta;
                if (Math.abs(delta) > 3) state.drag.moved = true;
                if (state.drag.moved) {
                    if (!state.open) setOpen(true, true);
                    setWidth(state.drag.startWidth + delta, false);
                }
            });

            window.addEventListener('pointerup', function(event) {
                if (!state.drag || state.drag.pointerId !== event.pointerId) return;
                state.ignoreNextClick = state.drag.moved;
                if (state.drag.moved) writeStorage(widthKey, String(state.width));
                state.drag = null;
                window.setTimeout(function() {
                    state.ignoreNextClick = false;
                }, 0);
            });

            window.addEventListener('pointercancel', function() {
                state.drag = null;
            });

            handle.addEventListener('click', function(event) {
                if (state.ignoreNextClick) {
                    event.preventDefault();
                    event.stopPropagation();
                    state.ignoreNextClick = false;
                    return;
                }
                setOpen(!state.open, true);
            });

            handle.addEventListener('keydown', function(event) {
                if (event.key !== 'ArrowLeft' && event.key !== 'ArrowRight') return;
                event.preventDefault();
                var delta = event.key === 'ArrowRight' ? 16 : -16;
                if (side === 'right') delta = -delta;
                setOpen(true, true);
                setWidth(state.width + delta, true);
            });
        });

        window.addEventListener('resize', function() {
            states.forEach(function(state) {
                state.sidebar.classList.toggle(
                    'theme-sidebar-mobile-open',
                    state.open && isMobile()
                );
            });
        });
    }

    window.initSidebarControls = initSidebarControls;

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSidebarControls);
    } else {
        initSidebarControls();
    }
})();
(function () {
    function qs(selector) {
        return document.querySelector(selector);
    }

    function qsa(selector) {
        return Array.prototype.slice.call(document.querySelectorAll(selector));
    }

    function normalize(str) {
        return (str || '').toString().toLowerCase().trim();
    }

    function initSidebarActive() {
        var path = window.location.pathname || '';
        var rules = [
            { match: '/dashboard', nav: 'dashboard' },
            { match: '/deliveryAssignment', nav: 'deliveryAssignment' },
            { match: '/warehouse', nav: 'warehouse' },
            { match: '/deliveryPoint', nav: 'deliveryPoint' },
            { match: '/location', nav: 'location' }
        ];

        var activeNav = null;
        for (var i = 0; i < rules.length; i++) {
            if (path.indexOf(rules[i].match) !== -1) {
                activeNav = rules[i].nav;
                break;
            }
        }
        if (!activeNav) return;

        qsa('.ds-nav-link').forEach(function (link) {
            if (link.getAttribute('data-nav') === activeNav) link.classList.add('active');
        });
    }

    function initSearchFilter() {
        var input = qs('#ds-searchAssignments');
        if (!input) return;

        var rows = qsa('#ds-activityTbody .ds-activity-row');

        input.addEventListener('input', function () {
            var q = normalize(input.value);
            if (!q) {
                rows.forEach(function (r) { r.style.display = ''; });
                return;
            }

            rows.forEach(function (row) {
                var haystack =
                    normalize(row.dataset.warehouse) + ' ' +
                    normalize(row.dataset.deliveryPoint) + ' ' +
                    normalize(row.dataset.priority) + ' ' +
                    normalize(row.dataset.status);

                row.style.display = haystack.indexOf(q) !== -1 ? '' : 'none';
            });
        });
    }

    function initAiQuickInsight() {
        var select = qs('#ds-aiLocationSelect');
        var btn = qs('#ds-aiRun');
        var output = qs('#ds-aiOutput');
        if (!select || !btn || !output) return;

        btn.addEventListener('click', function () {
            var locId = select.value;
            if (!locId) {
                output.textContent = 'Please select a location first.';
                return;
            }

            output.textContent = 'Loading insight...';

            var contextPath = (document.body && document.body.dataset && document.body.dataset.contextPath) ? document.body.dataset.contextPath : '';
            var url = contextPath + '/location/ajaxInsight/' + encodeURIComponent(locId);

            fetch(url, { method: 'GET', headers: { 'Accept': 'text/plain' } })
                .then(function (res) {
                    if (!res.ok) throw new Error('Request failed');
                    return res.text();
                })
                .then(function (text) {
                    output.textContent = text;
                })
                .catch(function () {
                    output.textContent = 'Could not load AI insight. Please try again.';
                });
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        initSidebarActive();
        initSearchFilter();
        initAiQuickInsight();
    });
})();


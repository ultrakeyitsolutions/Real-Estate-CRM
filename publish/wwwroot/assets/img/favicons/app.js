// Sidebar toggle functionality
document.addEventListener('DOMContentLoaded', function() {
    const sidebarToggle = document.querySelector('.sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    const main = document.querySelector('.main');

    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            // Check if we're in mobile view
            if (window.innerWidth < 992) {
                // Mobile: toggle 'show' class
                sidebar.classList.toggle('show');
            } else {
                // Desktop: toggle 'collapsed' class
                sidebar.classList.toggle('collapsed');
                main.classList.toggle('expanded');
            }
        });
    }

    // Close sidebar when clicking outside in mobile mode
    document.addEventListener('click', function(e) {
        if (window.innerWidth < 992) {
            const isClickInsideSidebar = sidebar.contains(e.target);
            const isClickOnToggle = sidebarToggle.contains(e.target);
            
            if (!isClickInsideSidebar && !isClickOnToggle && sidebar.classList.contains('show')) {
                sidebar.classList.remove('show');
            }
        }
    });

    // Prevent clicks inside sidebar from closing it
    if (sidebar) {
        sidebar.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }

    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth >= 992) {
            // Remove mobile 'show' class on desktop
            sidebar.classList.remove('show');
        } else {
            // Remove desktop 'collapsed' class on mobile
            sidebar.classList.remove('collapsed');
            main.classList.remove('expanded');
        }
    });

    // Initialize Feather Icons
    if (typeof feather !== 'undefined') {
        feather.replace();
    }
});

// Chart.js theme colors (for future use)
if (typeof window !== 'undefined') {
    window.theme = {
        primary: '#3b82f6',
        secondary: '#64748b',
        success: '#10b981',
        info: '#06b6d4',
        warning: '#f59e0b',
        danger: '#ef4444',
        light: '#f1f5f9',
        dark: '#1e293b'
    };
}

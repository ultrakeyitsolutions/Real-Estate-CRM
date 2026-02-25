/* -------------------------------------------------------------------------- */
/*                               Config                                       */
/* -------------------------------------------------------------------------- */
var CONFIG = {
  isNavbarVerticalCollapsed: false,
  theme: 'light',
  isRTL: false,
  isFluid: false,
  navbarStyle: 'transparent',
  navbarPosition: 'vertical'
};

Object.defineProperty(CONFIG, 'isNavbarVerticalCollapsed', {
  get: function get() {
    return localStorage.getItem('phoenixIsNavbarVerticalCollapsed') === 'true';
  },
  set: function set(value) {
    localStorage.setItem('phoenixIsNavbarVerticalCollapsed', value);
  }
});

Object.defineProperty(CONFIG, 'theme', {
  get: function get() {
    return localStorage.getItem('phoenixTheme') || 'light';
  },
  set: function set(value) {
    localStorage.setItem('phoenixTheme', value);
  }
});

Object.defineProperty(CONFIG, 'navbarPosition', {
  get: function get() {
    return localStorage.getItem('phoenixNavbarPosition') || 'vertical';
  },
  set: function set(value) {
    localStorage.setItem('phoenixNavbarPosition', value);
  }
});

Object.defineProperty(CONFIG, 'navbarStyle', {
  get: function get() {
    return localStorage.getItem('phoenixNavbarStyle') || 'transparent';
  },
  set: function set(value) {
    localStorage.setItem('phoenixNavbarStyle', value);
  }
});

/* -------------------------------------------------------------------------- */
/*                            Theme Initialization                            */
/* -------------------------------------------------------------------------- */
var config = {
  config: CONFIG
};

if (typeof window !== 'undefined') {
  window.config = config;
}

/* -------------------------------------------------------------------------- */
/*                               Set Theme                                    */
/* -------------------------------------------------------------------------- */
var setTheme = function setTheme() {
  var theme = CONFIG.theme;
  var isRTL = CONFIG.isRTL;
  
  if (theme === 'auto') {
    theme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }
  
  document.documentElement.setAttribute('data-bs-theme', theme);
  
  if (isRTL) {
    document.documentElement.setAttribute('dir', 'rtl');
  }
};

setTheme();

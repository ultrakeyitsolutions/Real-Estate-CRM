/* -------------------------------------------------------------------------- */
/*                                   Phoenix                                  */
/* -------------------------------------------------------------------------- */

(function(factory) {
  typeof define === 'function' && define.amd ? define(factory) :
  factory();
}(function() { 'use strict';

  /* -------------------------------------------------------------------------- */
  /*                            Navbar Vertical Toggle                          */
  /* -------------------------------------------------------------------------- */
  
  var toggleNavbarVertical = function() {
    var navbarVerticalToggle = document.querySelectorAll('.navbar-vertical-toggle');
    
    if (navbarVerticalToggle) {
      navbarVerticalToggle.forEach(function(toggle) {
        toggle.addEventListener('click', function(e) {
          e.preventDefault();
          var isCollapsed = document.documentElement.classList.contains('navbar-vertical-collapsed');
          
          if (isCollapsed) {
            document.documentElement.classList.remove('navbar-vertical-collapsed');
            localStorage.setItem('phoenixIsNavbarVerticalCollapsed', 'false');
          } else {
            document.documentElement.classList.add('navbar-vertical-collapsed');
            localStorage.setItem('phoenixIsNavbarVerticalCollapsed', 'true');
          }
        });
      });
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                                Theme Toggle                                */
  /* -------------------------------------------------------------------------- */
  
  var themeControl = function() {
    var themeController = document.body;
    
    if (themeController) {
      var currentTheme = localStorage.getItem('phoenixTheme') || 'light';
      document.documentElement.setAttribute('data-bs-theme', currentTheme);
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                              Tooltip Init                                  */
  /* -------------------------------------------------------------------------- */
  
  var tooltipInit = function() {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    
    if (typeof bootstrap !== 'undefined' && bootstrap.Tooltip) {
      tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
      });
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                                 Dropdown                                   */
  /* -------------------------------------------------------------------------- */
  
  var dropdownInit = function() {
    var dropdownElementList = [].slice.call(document.querySelectorAll('[data-bs-toggle="dropdown"]'));
    
    if (typeof bootstrap !== 'undefined' && bootstrap.Dropdown) {
      dropdownElementList.map(function(dropdownToggleEl) {
        return new bootstrap.Dropdown(dropdownToggleEl);
      });
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                                 Feather Icons                              */
  /* -------------------------------------------------------------------------- */
  
  var featherIconsInit = function() {
    if (typeof feather !== 'undefined') {
      feather.replace({
        width: '16px',
        height: '16px'
      });
    }
  };

  /* -------------------------------------------------------------------------- */
  /*                               DOM Loaded Event                             */
  /* -------------------------------------------------------------------------- */
  
  document.addEventListener('DOMContentLoaded', function() {
    toggleNavbarVertical();
    themeControl();
    tooltipInit();
    dropdownInit();
    featherIconsInit();
  });

}));

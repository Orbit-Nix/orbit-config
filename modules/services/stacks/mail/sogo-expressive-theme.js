/**
 * ============================================================================
 * SOGo Webmail - Modern Expressive (Material 3) Theme
 * Repository: https://github.com/vasskaroly-cvk/sogo-expressive-theme
 * Version: 2.5
 * Author: Károly Vass (cvk.hu)
 * License: MIT
 * ============================================================================
 */

(function() {
  'use strict';

  angular.module('SOGo.Common')
    .config(configure)
    .run(applyExpressiveTheme);

  /* ======================================================
     1. ANGULAR THEME PALETTA CONFIG
     ====================================================== */
  configure.$inject = ['$mdThemingProvider'];
  function configure($mdThemingProvider) {
    var expressiveBlue = $mdThemingProvider.extendPalette('blue', {
      '50': 'c2e7ff', '100': 'c2e7ff', '200': 'c2e7ff', '300': 'c2e7ff',
      '400': 'c2e7ff', '500': 'c2e7ff', '600': 'c2e7ff', '700': 'c2e7ff',
      '800': 'c2e7ff', '900': 'c2e7ff', 'A100': 'c2e7ff', 'A200': 'c2e7ff',
      'A400': 'c2e7ff', 'A700': 'c2e7ff',
      'contrastDefaultColor': 'dark'
    });
    
    $mdThemingProvider.definePalette('expressiveBlue', expressiveBlue);

    $mdThemingProvider.theme('default')
      .primaryPalette('expressiveBlue', { 'default': '500' }) 
      .accentPalette('expressiveBlue'); 
      
    $mdThemingProvider.generateThemesOnDemand(false);
  }

  /* ======================================================
     2. DUPLEX TÉMAMOTOR ÉS TISZTA CSS
     ====================================================== */
  applyExpressiveTheme.$inject = ['$interval', '$timeout'];
  function applyExpressiveTheme($interval, $timeout) {

    function getThemeColors() {
      var val = null;
      try {
        val = localStorage.getItem('sogo_theme') || 
              localStorage.getItem('theme') || 
              localStorage.getItem('theme_mode') || 
              localStorage.getItem('mailcow_theme');
      } catch(e) {}

      if (!val) {
        try {
          if (window.parent && window.parent !== window && window.parent.localStorage) {
            val = window.parent.localStorage.getItem('sogo_theme') || 
                  window.parent.localStorage.getItem('theme') || 
                  window.parent.localStorage.getItem('theme_mode');
          }
        } catch(e) {}
      }

      if (!val) {
        try {
          var match = document.cookie.match(/(?:^|; )\s*(?:sogo_theme|theme|theme_mode)=([^;]*)/);
          if (match) val = decodeURIComponent(match[1]);
        } catch(e) {}
      }

      var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      var isDark = false;
      if (val === 'dark') isDark = true;
      else if (val === 'light') isDark = false;
      else isDark = prefersDark;

      if (isDark) {
        return {
          isDark: true,
          bgMain: '#2e3b4b',          
          bgCard: '#364454',          
          bgHeader: '#273342',        
          bgHover: '#425266',         
          bgActiveFolder: '#34475e',  
          borderActiveFolder: '#4a6382',
          borderLeftActiveFolder: '#66b2ff',
          textActiveFolder: '#ffffff',
          iconActiveFolder: '#66b2ff',
          bgActivePanel: '#415266',    
          borderActivePanel: '#66b2ff',
          textActivePanel: '#ffffff',  
          bgUnreadFolder: '#2b3947',  
          borderUnreadFolder: '#3b4e63',
          textUnreadFolder: '#ffffff',
          iconUnreadFolder: '#93c5fd',
          bgStarSoft: '#423b20',
          borderStarSoft: '#eab308',
          textStar: '#fef08a',
          textMain: '#d3dbe2',        
          textPrimary: '#ffffff',     
          textMuted: '#a0b3c6',
          iconColor: '#ffffff',
          accentBtn: '#66b2ff',       
          accentFab: '#66b2ff',       
          fabIcon: '#111a22',         
          border: '#273342'           
        };
      } else {
        return {
          isDark: false,
          bgMain: '#f4f7fc',
          bgCard: '#ffffff',
          bgHeader: '#f4f7fc',
          bgHover: '#edf2f7',
          bgActiveFolder: '#cbe6fc',          
          borderActiveFolder: '#99cfff',      
          borderLeftActiveFolder: '#0056b3',  
          textActiveFolder: '#002244',
          iconActiveFolder: '#002244',
          bgActivePanel: '#dbeafe',          
          borderActivePanel: '#0b57d0',
          textActivePanel: '#041e49',
          bgUnreadFolder: '#eef5fd',          
          borderUnreadFolder: '#dbeafe',
          textUnreadFolder: '#041e49',
          iconUnreadFolder: '#041e49',
          bgStarSoft: '#fef9c3',              
          borderStarSoft: '#fde047',
          textStar: '#713f12',
          textMain: '#0f172a',
          textPrimary: '#041e49',
          textMuted: '#475569',
          iconColor: '#041e49',
          accentBtn: '#041e49',
          accentFab: '#c2e7ff',
          fabIcon: '#001d35',
          border: '#e2e8f0'
        };
      }
    }

    function isMessageSelected(item) {
      if (!item) return false;
      return (item.classList.contains('md-bg') && item.classList.contains('md-hue-2')) ||
             item.classList.contains('sg-message-selected') ||
             item.classList.contains('md-active') ||
             item.classList.contains('sg-item-selected') ||
             item.classList.contains('sg-selected') ||
             item.getAttribute('aria-selected') === 'true' ||
             item.querySelector('.md-bg.md-hue-2, .sg-message-selected, .md-active, .sg-item-selected, .sg-selected, [aria-selected="true"]') !== null;
    }

    function isMessageStarred(item) {
      if (!item) return false;
      return item.classList.contains('sg-star-bg') || item.querySelector('.sg-star-bg') !== null;
    }

    // Univerzális aktív mappa és címjegyzék vizsgálat
    function isFolderActive(folder) {
      if (!folder) return false;

      // 1. SOGo natív kijelölési osztályai
      if (folder.classList.contains('md-active') ||
          folder.classList.contains('sg-folder-selected') ||
          folder.classList.contains('sg-item-selected') ||
          folder.classList.contains('sg-selected') ||
          (folder.classList.contains('md-bg') && folder.classList.contains('md-hue-2')) ||
          folder.getAttribute('aria-selected') === 'true' ||
          folder.querySelector('.md-active, .sg-folder-selected, .sg-item-selected, .sg-selected, [aria-selected="true"]') !== null) {
        return true;
      }

      // 2. Fejléc címsorának dinamikus vizsgálata
      var titleNode = document.querySelector('.sg-folder-name, [ui-view="main"] md-toolbar .md-toolbar-tools > span, [ui-view="main"] md-toolbar h2, .sg-toolbar-tools span');
      var currentTitle = (titleNode && titleNode.textContent ? titleNode.textContent.trim().toLowerCase() : '');
      
      if (!currentTitle) {
        var searchInput = document.querySelector('input.sg-filter-input, form.sg-filter input');
        if (searchInput && searchInput.placeholder) {
          var m = searchInput.placeholder.match(/:\s*(.+)$/);
          if (m) currentTitle = m[1].trim().toLowerCase();
        }
      }

      if (currentTitle && currentTitle.length > 1 && currentTitle !== 'sogo') {
        var fText = (folder.querySelector('p, span, .sg-name, .md-body-1')?.textContent || folder.textContent || '').trim().toLowerCase();
        fText = fText.replace(/[|:–—\(\[].*$/, '').trim();
        if (fText === currentTitle) {
          return true;
        }
      }

      return false;
    }

    // Univerzális és biztos olvasatlan mappa vizsgálat
    function isFolderUnread(folder) {
      if (!folder) return false;

      // 1. Natív osztályok
      if (folder.classList.contains('sg-unread') || 
          folder.classList.contains('sg-folder-unread')) {
        return true;
      }

      // 2. Látható jelvények
      var badge = folder.querySelector('.sg-badge:not(.ng-hide), .sg-unread-count:not(.ng-hide)');
      if (badge) {
        var count = parseInt((badge.textContent || '').replace(/\D/g, ''), 10);
        if (!isNaN(count) && count > 0) return true;
      }

      // 3. Szöveges tartalom vizsgálata
      var raw = ((folder.innerText || '') + ' ' + (folder.textContent || '')).replace(/more_vert/g, '').trim();
      
      if (/[|:–—\(\[]\s*[1-9]\d*/.test(raw)) return true;
      if (/\([1-9]\d*\)/.test(raw) || /\[[1-9]\d*\]/.test(raw)) return true;
      if (/\b([1-9]\d{0,2})\b/.test(raw)) return true;

      return false;
    }

    function injectPersistentStyle() {
      var colors = getThemeColors();
      
      if (colors.isDark) {
        document.documentElement.classList.remove('sogo-light');
        document.documentElement.classList.add('sogo-dark');
      } else {
        document.documentElement.classList.remove('sogo-dark');
        document.documentElement.classList.add('sogo-light');
      }

      var styleId = 'sogo-expressive-theme-v2';
      var style = document.getElementById(styleId);

      if (!style) {
        style = document.createElement('style');
        style.id = styleId;
        document.head.appendChild(style);
      } else {
        if (document.head.lastElementChild !== style) {
          document.head.appendChild(style);
        }
      }

      var shadow3D = colors.isDark 
        ? '0 12px 32px rgba(0, 0, 0, 0.75), 0 0 24px rgba(255, 255, 255, 0.22), 0 2px 8px rgba(255, 255, 255, 0.15)' 
        : '0 12px 28px rgba(0, 0, 0, 0.15), 0 4px 10px rgba(0, 0, 0, 0.08)';

      style.textContent = `
        /* Root Canvas */
        html, body {
            background-color: ${colors.bgMain} !important;
            height: 100vh !important;
            max-height: 100vh !important;
            box-sizing: border-box !important;
            overflow: hidden !important;
            color: ${colors.textMain} !important;
        }

        .sg-main-view, [ui-view="main"], .sg-main-container,
        .layout-row, .layout-column {
            background-color: ${colors.bgMain} !important;
            box-sizing: border-box !important;
        }

        md-toolbar, .sg-header md-toolbar {
            background-color: ${colors.bgHeader} !important;
            color: ${colors.textMain} !important;
            box-shadow: none !important;
        }

        /* Lebegő Nap/Hold gomb */
        #sogo-theme-toggle-btn {
            position: fixed !important;
            left: 50% !important;
            top: 10px !important;
            transform: translateX(-50%) !important;
            z-index: 40 !important;
            background: ${colors.isDark ? '#364454' : '#ffffff'} !important;
            border: 1px solid ${colors.border} !important;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
            width: 38px !important;
            height: 38px !important;
            border-radius: 50% !important;
            cursor: pointer !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 18px !important;
            transition: all 0.2s ease !important;
        }
        #sogo-theme-toggle-btn:hover {
            transform: translateX(-50%) scale(1.15) !important;
            box-shadow: 0 6px 16px rgba(0,0,0,0.25) !important;
        }

        /* Fiók infó & Kvótasáv: Olyan sötét mint az ikonok (#041e49) */
        .sg-user-info {
            padding: 10px 14px 6px 14px !important;
            display: flex !important;
            flex-direction: row !important;
            align-items: center !important;
            background: transparent !important;
        }

        .sg-user-info .sg-user-name {
            color: ${colors.textPrimary} !important;
            font-weight: 700 !important;
            font-size: 15px !important;
        }

        .sg-user-info .sg-user-email,
        .sg-user-info span,
        .sg-user-info .md-caption {
            color: ${colors.isDark ? '#d3dbe2' : '#041e49'} !important;
            font-weight: 700 !important;
            opacity: 1 !important;
        }

        md-sidenav [aria-label*="@"],
        md-sidenav [ng-click*="account"],
        md-sidenav .sg-account-item {
            background: transparent !important;
            border: none !important;
            border-radius: 0 !important;
        }

        md-sidenav [aria-label*="@"] *,
        md-sidenav [ng-click*="account"] *,
        md-sidenav .sg-account-item * {
            color: ${colors.isDark ? '#ffffff' : '#041e49'} !important;
            fill: ${colors.isDark ? '#ffffff' : '#041e49'} !important;
            font-weight: 700 !important;
            opacity: 1 !important;
        }

        .sg-quota, .sg-quota-info, [ng-show*="quota"] {
            height: auto !important;
            max-height: none !important;
            overflow: visible !important;
            display: block !important;
            visibility: visible !important;
            background: transparent !important;
        }

        .sg-quota *, .sg-quota-text, .sg-quota-label, [ng-show*="quota"] * {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            color: ${colors.isDark ? '#ffffff' : '#041e49'} !important;
            font-size: 11px !important;
            font-weight: 700 !important;
            padding: 4px 14px 2px 14px !important;
            margin: 0 !important;
        }

        md-progress-linear .md-bar1 { display: none !important; visibility: hidden !important; }
        md-progress-linear .md-container { background-color: ${colors.isDark ? '#273342' : '#cbd5e1'} !important; border-radius: 4px !important; height: 5px !important; }
        md-progress-linear .md-bar2 { background-color: ${colors.isDark ? '#66b2ff' : '#041e49'} !important; border-radius: 4px !important; height: 5px !important; }

        /* Oldalsáv & Mappák alapstílusa */
        md-sidenav,
        md-sidenav.md-locked-open,
        md-sidenav md-content,
        md-sidenav md-content.md-default-theme,
        .sg-folder-list,
        .sg-contacts-sidebar,
        .sg-calendar-sidebar {
            background-color: ${colors.bgMain} !important;
            background: ${colors.bgMain} !important;
            border: none !important;
            border-bottom-left-radius: 20px !important;
            border-bottom-right-radius: 20px !important;
            margin-bottom: 8px !important;
            height: calc(100% - 8px) !important;
            max-height: calc(100% - 8px) !important;
            overflow: hidden !important;
            box-sizing: border-box !important;
        }

        md-sidenav md-list-item:not(.sg-user-info) {
            margin: 2px 8px !important;
            width: calc(100% - 16px) !important;
            border-radius: 8px !important;
            border: 1px solid transparent !important;
            box-sizing: border-box !important;
            transition: background-color 0.15s ease !important;
        }

        md-sidenav md-list-item:not(.sg-user-info):hover { 
            background-color: ${colors.bgHover} !important; 
        }

        /* Fejlécek a bal oldalsávban */
        md-sidenav md-subheader,
        md-sidenav .md-subheader,
        md-sidenav .md-subheader-inner,
        .sg-contacts-sidebar md-subheader,
        .sg-calendar-sidebar md-subheader {
            background-color: transparent !important;
            background: transparent !important;
            color: ${colors.textMuted} !important;
            font-weight: 700 !important;
            border: none !important;
        }

        /* MAPPALISTA IKONOK: SÖTÉTKÉKEK ÉS NEM FAKÓK! */
        html.sogo-light md-sidenav md-list-item md-icon,
        html.sogo-light md-sidenav md-list-item svg,
        html.sogo-light .sg-folder-list md-icon,
        html.sogo-light .sg-contacts-sidebar md-icon {
            color: #041e49 !important;
            fill: #041e49 !important;
            opacity: 1 !important;
        }

        html.sogo-dark md-sidenav md-list-item *,
        html.sogo-dark md-sidenav md-list-item p,
        html.sogo-dark md-sidenav md-list-item span,
        html.sogo-dark .sg-calendar-sidebar p,
        html.sogo-dark .sg-calendar-sidebar span {
            color: #d3dbe2 !important;
            font-weight: 500 !important;
        }

        html.sogo-dark md-sidenav md-list-item md-icon,
        html.sogo-dark md-sidenav md-list-item svg {
            color: #ffffff !important;
            fill: #ffffff !important;
        }

        /* CÍMJEGYZÉK KIVÁLASZTOTT ELEM BELSŐ RÉTEG ÁTTETSZŐSÉG */
        md-sidenav md-list-item .md-list-item-inner,
        md-sidenav md-list-item .md-list-item-text {
            background: transparent !important;
            background-color: transparent !important;
        }

        html.sogo-light md-sidenav md-list-item.md-active *,
        html.sogo-light md-sidenav md-list-item.sg-folder-selected *,
        html.sogo-light md-sidenav md-list-item.sg-item-selected * {
            color: #002244 !important;
            -webkit-text-fill-color: #002244 !important;
            opacity: 1 !important;
            visibility: visible !important;
        }

        html.sogo-dark md-sidenav md-list-item.md-active *,
        html.sogo-dark md-sidenav md-list-item.sg-folder-selected *,
        html.sogo-dark md-sidenav md-list-item.sg-item-selected * {
            color: #ffffff !important;
            -webkit-text-fill-color: #ffffff !important;
            opacity: 1 !important;
            visibility: visible !important;
        }

        /* Fő kártyák és panelek */
        [ui-view="list"], [ui-view="detail"], [ui-view="contacts"], [ui-view="preferences"] {
            background-color: transparent !important;
            box-sizing: border-box !important;
            padding-bottom: 0 !important;
            margin-bottom: 0 !important;
            overflow: visible !important;
        }

        [id="messagesList"], [id="contactsList"], .sg-list, .sg-contacts-list {
            background-color: ${colors.bgCard} !important;
            border-radius: 20px !important;
            margin: 8px 4px 8px 6px !important;
            height: calc(100% - 16px) !important;
            max-height: calc(100% - 16px) !important;
            box-shadow: ${shadow3D} !important;
            overflow: hidden !important;
            border: 1px solid ${colors.border} !important;
            box-sizing: border-box !important;
            color: ${colors.textMain} !important;
        }

        md-card, [id="mailView"], [id="messageView"], .sg-mail-view, [id="contactView"], .sg-contact-view {
            background-color: ${colors.bgCard} !important;
            border-top-left-radius: 0 !important;
            border-top-right-radius: 0 !important;
            border-bottom-left-radius: 20px !important;
            border-bottom-right-radius: 20px !important;
            margin: 0 12px 8px 4px !important;
            height: calc(100% - 8px) !important;
            max-height: calc(100% - 8px) !important;
            box-shadow: ${shadow3D} !important;
            overflow: hidden !important;
            border: 1px solid ${colors.border} !important;
            box-sizing: border-box !important;
            color: ${colors.textMain} !important;
        }

        .sg-list md-toolbar, [id="messagesList"] md-toolbar, [id="contactsList"] md-toolbar {
            background-color: ${colors.bgCard} !important;
            border-bottom: 1px solid ${colors.border} !important;
            border-top-left-radius: 20px !important;
            border-top-right-radius: 20px !important;
            color: ${colors.textMain} !important;
        }

        .sg-mail-view md-toolbar, [id="mailView"] md-toolbar, [id="messageView"] md-toolbar, md-card md-toolbar, .sg-contact-view md-toolbar {
            background-color: ${colors.bgCard} !important;
            border-bottom: 1px solid ${colors.border} !important;
            border-radius: 0 !important;
            color: ${colors.textMain} !important;
        }

        .sg-mail-body:after, .sg-mail-container:after, .sg-mail-view:after, [id="mailView"]:after, [id="messageView"]:after, md-card:after {
            content: ' ' !important; display: block !important; height: 16px !important; min-height: 16px !important; width: 100% !important; clear: both !important;
        }

        .sg-mail-headers, .sg-mail-subject, .sg-mail-header-values { color: ${colors.textMain} !important; }
        .sg-mail-headers .sg-mail-header-labels, .sg-mail-headers .sg-mail-header-label, .sg-mail-headers .md-caption, .sg-mail-headers label { color: ${colors.textMuted} !important; }
        .sg-mail-headers a, .sg-mail-header-values a, .sg-mail-attachments a { color: ${colors.accentBtn} !important; text-decoration: underline !important; }

        /* Címjegyzék linkek sötétben */
        html.sogo-dark [id="contactView"] a,
        html.sogo-dark .sg-contact-view a,
        html.sogo-dark [ui-view="detail"] a {
            color: #66b2ff !important;
            text-decoration: underline !important;
        }

        /* Naptár modul elrendezés */
        .sg-calendar-container,
        [ui-view="calendars"],
        [ui-view="calendar"] {
            display: flex !important;
            flex-direction: row !important;
            height: calc(100% - 8px) !important;
            max-height: calc(100% - 8px) !important;
            overflow: hidden !important;
            box-sizing: border-box !important;
            background: transparent !important;
        }

        .sg-calendar-sidebar,
        md-sidenav.sg-calendar-sidebar {
            display: flex !important;
            flex-direction: column !important;
            width: 260px !important;
            min-width: 260px !important;
            max-width: 260px !important;
            height: 100% !important;
            background-color: ${colors.bgMain} !important;
            border-radius: 20px !important;
            overflow: hidden !important;
            border: none !important;
        }

        .sg-calendar-sidebar md-list-item {
            overflow: hidden !important;
            border-radius: 8px !important;
        }

        #calendarView,
        .sg-calendar-view {
            display: flex !important;
            flex-direction: column !important;
            flex: 1 1 0% !important;
            height: 100% !important;
            margin: 0 12px 0 6px !important;
            background-color: ${colors.bgCard} !important;
            border-radius: 20px !important;
            border: 1px solid ${colors.border} !important;
            box-shadow: ${shadow3D} !important;
            overflow: hidden !important;
        }

        #calendarView md-content,
        .sg-calendar-view md-content,
        .sg-calendar-view-content,
        .sg-calendar-scroll-view,
        .calendarView,
        .sg-calendar-body,
        .sg-day-view,
        .sg-week-view,
        .sg-month-view {
            flex: 1 1 0% !important;
            height: 100% !important;
            overflow: auto !important;
            background-color: ${colors.bgCard} !important;
        }

        /* Naptárrács sötétben */
        html.sogo-dark [ui-view="calendars"] td,
        html.sogo-dark [ui-view="calendars"] th,
        html.sogo-dark [ui-view="calendars"] tr,
        html.sogo-dark [ui-view="calendars"] table,
        html.sogo-dark [ui-view="calendar"] td,
        html.sogo-dark [ui-view="calendar"] th,
        html.sogo-dark [ui-view="calendar"] tr,
        html.sogo-dark [ui-view="calendar"] table,
        html.sogo-dark #calendarView td,
        html.sogo-dark #calendarView th,
        html.sogo-dark #calendarView tr,
        html.sogo-dark #calendarView table,
        html.sogo-dark .calendarView td,
        html.sogo-dark .calendarView tr,
        html.sogo-dark .calendarView table,
        html.sogo-dark .calendarView,
        html.sogo-dark .allDaysView,
        html.sogo-dark .hours,
        html.sogo-dark .hour,
        html.sogo-dark .day,
        html.sogo-dark .days,
        html.sogo-dark .sg-calendar-grid,
        html.sogo-dark td[class*="off"],
        html.sogo-dark td[class*="nonWorking"] {
            background-color: #364454 !important;
            background: #364454 !important;
            border-color: #273342 !important;
            color: #ffffff !important;
        }

        html.sogo-dark .sg-calendar-hour-header,
        html.sogo-dark .sg-calendar-time,
        html.sogo-dark .hour {
            color: #a0b3c6 !important;
        }

        /* Naptárrács világosban */
        html.sogo-light [ui-view="calendars"] td,
        html.sogo-light [ui-view="calendar"] td,
        html.sogo-light #calendarView td,
        html.sogo-light .calendarView td {
            background-color: #ffffff !important;
            border-color: #e2e8f0 !important;
        }
        html.sogo-light td[class*="off"],
        html.sogo-light td[class*="nonWorking"] {
            background-color: #f8fafc !important;
        }

        /* NAPTÁR ÉS CÍMJEGYZÉK SZERKESZTŐ POPUP */
        md-dialog {
            max-height: 90vh !important;
            height: auto !important;
            display: flex !important;
            flex-direction: column !important;
            border-radius: 16px !important;
            overflow: hidden !important;
            box-shadow: 0 16px 40px rgba(0,0,0,0.4) !important;
            background-color: ${colors.bgCard} !important;
            color: ${colors.textMain} !important;
        }

        md-dialog-content,
        md-dialog .md-dialog-content,
        md-dialog md-content,
        md-dialog form,
        .sg-event-editor,
        .sg-contact-editor,
        .sg-card-editor,
        form[name="eventForm"],
        form[name="cardForm"],
        form[name="contactForm"] {
            overflow: auto !important;
            overflow-y: auto !important;
            flex: 1 1 auto !important;
            max-height: calc(90vh - 110px) !important;
            -webkit-overflow-scrolling: touch !important;
            background-color: ${colors.bgCard} !important;
        }

        md-dialog input,
        md-dialog textarea,
        md-dialog md-select,
        md-dialog .md-select-value,
        .sg-event-editor input {
            color: ${colors.isDark ? '#ffffff' : '#041e49'} !important;
            font-weight: 600 !important;
            font-size: 14px !important;
        }

        md-dialog label,
        md-dialog .md-caption,
        md-dialog md-input-container label {
            color: ${colors.isDark ? '#a0b3c6' : '#5f6368'} !important;
            font-weight: 500 !important;
        }

        md-dialog input[name="summary"],
        md-dialog input.md-input:first-of-type,
        .sg-event-editor input.md-input:first-of-type {
            font-size: 18px !important;
            font-weight: 700 !important;
            color: ${colors.isDark ? '#ffffff' : '#041e49'} !important;
        }

        /* Rögzített gombsor a felugró ablak alján */
        md-dialog md-dialog-actions,
        md-dialog .md-actions,
        md-dialog-actions {
            flex-shrink: 0 !important;
            position: sticky !important;
            bottom: 0 !important;
            z-index: 10 !important;
            background-color: ${colors.bgCard} !important;
            border-top: 1px solid ${colors.border} !important;
            padding: 10px 16px !important;
            display: flex !important;
            justify-content: flex-end !important;
        }

        md-dialog md-dialog-actions button,
        md-dialog .md-actions button {
            color: ${colors.accentBtn} !important;
            font-weight: 700 !important;
            border-radius: 16px !important;
        }

        md-dialog md-dialog-actions button[type="submit"],
        md-dialog md-dialog-actions button.md-primary {
            background-color: ${colors.accentBtn} !important;
            color: ${colors.isDark ? '#111a22' : '#ffffff'} !important;
            padding: 4px 16px !important;
        }

        /* Levéllista formázás */
        [ui-view="list"] md-progress-linear, #messagesList md-progress-linear { display: none !important; }
        [ui-view="list"] md-divider, #messagesList md-divider, [ui-view="list"] md-list-item:after, #messagesList md-list-item:after { display: none !important; }
        [id="messagesList"] md-subheader, [id="messagesList"] .md-subheader { background-color: transparent !important; color: ${colors.textMuted} !important; }

        [ui-view="list"] md-list-item, #messagesList md-list-item {
            margin: 3px 6px !important; width: calc(100% - 12px) !important; border-radius: 8px !important;
            border: 1px solid transparent !important; box-sizing: border-box !important; overflow: hidden !important; transition: all 0.15s ease !important; color: ${colors.textMain} !important;
        }
        [ui-view="list"] md-list-item:hover, #messagesList md-list-item:hover { background-color: ${colors.bgHover} !important; border-color: ${colors.border} !important; }

        /* Globális Ikonok */
        html.sogo-light md-icon, html.sogo-light button md-icon, html.sogo-light a md-icon, html.sogo-light md-button md-icon { color: #041e49 !important; fill: #041e49 !important; opacity: 1 !important; }
        html.sogo-dark md-icon, html.sogo-dark button md-icon, html.sogo-dark a md-icon, html.sogo-dark md-button md-icon { color: #ffffff !important; fill: #ffffff !important; opacity: 1 !important; }

        button md-icon, a md-icon, md-button md-icon { transition: transform 0.2s cubic-bezier(0.25, 0.8, 0.25, 1) !important; }
        button:hover md-icon, a:hover md-icon, md-button:hover md-icon { transform: scale(1.18) !important; }

        button.md-fab { background-color: ${colors.accentFab} !important; border-radius: 14px !important; }
        button.md-fab md-icon { color: ${colors.fabIcon} !important; fill: ${colors.fabIcon} !important; }

        .ck.ck-toolbar { background-color: ${colors.bgHeader} !important; border-color: ${colors.border} !important; }
        .ck.ck-editor__main, [contenteditable="true"].ck-content { background-color: ${colors.bgCard} !important; color: ${colors.textPrimary} !important; }
        html.sogo-dark .md-open-menu-container, html.sogo-dark md-menu-content { background-color: ${colors.bgCard} !important; border: 1px solid ${colors.border} !important; border-radius: 12px !important; }

        ::-webkit-scrollbar { width: 8px !important; height: 8px !important; }
        ::-webkit-scrollbar-track { background: transparent !important; }
        ::-webkit-scrollbar-thumb { background: ${colors.border} !important; border-radius: 4px !important; }
      `;
    }

    function injectThemeToggleButton() {
      if (document.getElementById('sogo-theme-toggle-btn')) return;

      var btn = document.createElement('button');
      btn.id = 'sogo-theme-toggle-btn';
      btn.type = 'button';
      
      var colors = getThemeColors();
      btn.innerHTML = colors.isDark ? '☀️' : '🌙';
      btn.title = colors.isDark ? 'Váltás Expressive Light módra' : 'Váltás Expressive Dark módra';

      btn.onclick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        var isDarkNow = getThemeColors().isDark;
        var newTheme = isDarkNow ? 'light' : 'dark';
        
        try {
          localStorage.setItem('sogo_theme', newTheme);
          localStorage.setItem('theme', newTheme);
          localStorage.setItem('theme_mode', newTheme);
          if (window.parent && window.parent.localStorage) {
            window.parent.localStorage.setItem('sogo_theme', newTheme);
            window.parent.localStorage.setItem('theme', newTheme);
          }
        } catch(err) {}

        btn.innerHTML = newTheme === 'dark' ? '☀️' : '🌙';
        btn.title = newTheme === 'dark' ? 'Váltás Expressive Light módra' : 'Váltás Expressive Dark módra';

        injectPersistentStyle();
        enforceUniformCardBaseline();
        syncActiveItemsAndFolders();
      };

      document.body.appendChild(btn);
    }

    function enforceUniformCardBaseline() {
      var colors = getThemeColors();

      var shadow3D = colors.isDark 
        ? '0 12px 32px rgba(0, 0, 0, 0.75), 0 0 24px rgba(255, 255, 255, 0.22), 0 2px 8px rgba(255, 255, 255, 0.15)' 
        : '0 12px 28px rgba(0, 0, 0, 0.15), 0 4px 10px rgba(0, 0, 0, 0.08)';

      var parentContainers = document.querySelectorAll('[ui-view="list"], [ui-view="detail"], [ui-view="contacts"], [ui-view="preferences"]');
      for (var p = 0; p < parentContainers.length; p++) {
        parentContainers[p].style.setProperty('overflow', 'visible', 'important');
      }

      var sideNavs = document.querySelectorAll('md-sidenav, md-sidenav.md-locked-open, md-sidenav md-content, .sg-folder-list, .sg-contacts-sidebar, .sg-calendar-sidebar');
      for (var s = 0; s < sideNavs.length; s++) {
        var sn = sideNavs[s];
        sn.style.setProperty('background-color', colors.bgMain, 'important');
        sn.style.setProperty('border', 'none', 'important');
        sn.style.setProperty('border-bottom-left-radius', '20px', 'important');
        sn.style.setProperty('border-bottom-right-radius', '20px', 'important');
        sn.style.setProperty('margin-bottom', '8px', 'important');
        sn.style.setProperty('height', 'calc(100% - 8px)', 'important');
        sn.style.setProperty('max-height', 'calc(100% - 8px)', 'important');
        sn.style.setProperty('overflow', 'hidden', 'important');
      }

      var listCards = document.querySelectorAll('#messagesList, #contactsList, .sg-list, .sg-contacts-list');
      for (var l = 0; l < listCards.length; l++) {
        var lc = listCards[l];
        lc.style.setProperty('border-radius', '20px', 'important');
        lc.style.setProperty('margin', '8px 4px 8px 6px', 'important');
        lc.style.setProperty('height', 'calc(100% - 16px)', 'important');
        lc.style.setProperty('max-height', 'calc(100% - 16px)', 'important');
        lc.style.setProperty('overflow', 'hidden', 'important');
        lc.style.setProperty('background-color', colors.bgCard, 'important');
        lc.style.setProperty('box-shadow', shadow3D, 'important');
        lc.style.setProperty('border', '1px solid ' + colors.border, 'important');
      }

      var detailCards = document.querySelectorAll('md-card, .sg-mail-view, .sg-record-view, .sg-contact-view, .sg-card-view, #contactView, #cardView, #messageView, #mailView');
      for (var d = 0; d < detailCards.length; d++) {
        var dc = detailCards[d];
        dc.style.setProperty('border-top-left-radius', '0px', 'important');
        dc.style.setProperty('border-top-right-radius', '0px', 'important');
        dc.style.setProperty('border-bottom-left-radius', '20px', 'important');
        dc.style.setProperty('border-bottom-right-radius', '20px', 'important');
        dc.style.setProperty('margin', '0px 12px 8px 4px', 'important');
        dc.style.setProperty('height', 'calc(100% - 8px)', 'important');
        dc.style.setProperty('max-height', 'calc(100% - 8px)', 'important');
        dc.style.setProperty('overflow', 'visible', 'important');
        dc.style.setProperty('background-color', colors.bgCard, 'important');
        dc.style.setProperty('box-shadow', shadow3D, 'important');
        dc.style.setProperty('border', '1px solid ' + colors.border, 'important');
      }

      var iframes = document.querySelectorAll('iframe, #messageFrame, .sg-mail-iframe');
      for (var i = 0; i < iframes.length; i++) {
        var iframe = iframes[i];
        try {
          if (iframe.contentDocument && iframe.contentDocument.body) {
            var ifDoc = iframe.contentDocument;
            var ifBody = ifDoc.body;
            ifBody.style.setProperty('padding-bottom', '16px', 'important');

            if (colors.isDark) {
              var ifStyle = ifDoc.getElementById('sogo-dark-iframe-fix');
              if (!ifStyle) {
                ifStyle = ifDoc.createElement('style');
                ifStyle.id = 'sogo-dark-iframe-fix';
                (ifDoc.head || ifDoc.body).appendChild(ifStyle);
              }
              ifStyle.textContent = `
                html, body { background-color: ${colors.bgCard} !important; color: #ffffff !important; }
                *, p, div, span, h1, h2, h3, h4, table, td, th { color: #ffffff !important; }
                a { color: ${colors.accentBtn} !important; }
              `;
              ifBody.style.setProperty('background-color', colors.bgCard, 'important');
              ifBody.style.setProperty('color', '#ffffff', 'important');
            } else {
              var ifStyleOld = ifDoc.getElementById('sogo-dark-iframe-fix');
              if (ifStyleOld) ifStyleOld.remove();
            }
          }
        } catch (e) {}
      }
    }

    /* ======================================================
       3. INTELIGENS AKTÍV PANEL- ÉS MAPPA KIJELÖLÉS
       ====================================================== */
    function syncActiveItemsAndFolders() {
      var colors = getThemeColors();
      var targetIconColor = colors.isDark ? '#ffffff' : '#041e49';

      // 1. Levéllista és Címjegyzék lista tételek szinkronizálása
      var items = document.querySelectorAll('[ui-view="list"] md-list-item, #messagesList md-list-item, [ui-view="contacts"] md-list-item, #contactsList md-list-item');
      for (var i = 0; i < items.length; i++) {
        var item = items[i];
        var selected = isMessageSelected(item);
        var starred = !selected && isMessageStarred(item);

        if (selected) {
          item.style.setProperty('background-color', colors.bgActivePanel, 'important');
          item.style.setProperty('border', '1px solid ' + colors.borderActivePanel, 'important');
          item.style.setProperty('border-left', '4px solid ' + colors.borderActivePanel, 'important');
          item.style.setProperty('border-radius', '8px', 'important');

          var kids = item.querySelectorAll('*');
          for (var j = 0; j < kids.length; j++) {
            kids[j].style.setProperty('color', colors.textActivePanel, 'important');
            kids[j].style.setProperty('fill', colors.textActivePanel, 'important');
          }
        } else if (starred) {
          item.style.setProperty('background-color', colors.bgStarSoft, 'important');
          item.style.setProperty('border', '1px solid ' + colors.borderStarSoft, 'important');
          item.style.setProperty('border-left', '4px solid ' + colors.borderStarSoft, 'important');
          item.style.setProperty('border-radius', '8px', 'important');

          var sKids = item.querySelectorAll('*');
          for (var sk = 0; sk < sKids.length; sk++) {
            sKids[sk].style.setProperty('color', colors.textStar, 'important');
            sKids[sk].style.setProperty('fill', colors.textStar, 'important');
          }
        } else {
          item.style.removeProperty('background-color');
          item.style.removeProperty('border-left');
          item.style.removeProperty('border');

          var unKids = item.querySelectorAll('*');
          for (var k = 0; k < unKids.length; k++) {
            unKids[k].style.removeProperty('color');
            unKids[k].style.removeProperty('fill');
          }
        }
      }

      // 2. Mappalista és Címjegyzék oldalsáv szinkronizálása
      var sideNavListItems = document.querySelectorAll('md-sidenav md-list-item');
      for (var f = 0; f < sideNavListItems.length; f++) {
        var folder = sideNavListItems[f];
        
        if (folder.classList.contains('sg-user-info') || folder.closest('.sg-user-info') || folder.querySelector('.sg-avatar, .sg-user-name')) {
          continue;
        }

        var isSel = isFolderActive(folder);
        var isUnread = !isSel && isFolderUnread(folder);

        if (isSel) {
          var actBg = colors.bgActiveFolder;
          var actBorder = colors.borderActiveFolder;
          var actLeftBar = colors.borderLeftActiveFolder;
          var actTxt = colors.textActiveFolder;
          var actIcon = colors.iconActiveFolder;

          folder.style.setProperty('background-color', actBg, 'important');
          folder.style.setProperty('background', actBg, 'important');
          folder.style.setProperty('border', '1px solid ' + actBorder, 'important');
          folder.style.borderLeft = '4px solid ' + actLeftBar;
          folder.style.setProperty('border-left', '4px solid ' + actLeftBar, 'important');
          folder.style.setProperty('border-radius', '8px', 'important');

          // A belső gombokat és szövegtartókat átlátszóvá tesszük, hogy ne fedjék le a szöveget és az ikont!
          var innerElements = folder.querySelectorAll('.md-button, .md-no-style, .md-list-item-inner, .md-list-item-text');
          for (var ie = 0; ie < innerElements.length; ie++) {
            innerElements[ie].style.setProperty('background', 'transparent', 'important');
            innerElements[ie].style.setProperty('background-color', 'transparent', 'important');
          }

          // A szövegek és ikonok garantáltan élesen látszanak
          var fKids = folder.querySelectorAll('*');
          for (var fk = 0; fk < fKids.length; fk++) {
            var node = fKids[fk];
            if (node.tagName === 'MD-ICON' || node.tagName === 'SVG' || node.tagName === 'PATH') {
              node.style.setProperty('color', actIcon, 'important');
              node.style.setProperty('fill', actIcon, 'important');
              node.style.setProperty('opacity', '1', 'important');
              node.style.setProperty('visibility', 'visible', 'important');
            } else if (!node.classList.contains('md-button') && !node.classList.contains('md-no-style') && !node.classList.contains('md-list-item-inner')) {
              node.style.setProperty('color', actTxt, 'important');
              node.style.setProperty('-webkit-text-fill-color', actTxt, 'important');
              node.style.setProperty('font-weight', '700', 'important');
              node.style.setProperty('opacity', '1', 'important');
              node.style.setProperty('visibility', 'visible', 'important');
            }
          }
        } else if (isUnread) {
          var unreadBg = colors.bgUnreadFolder;
          var unreadBorder = colors.borderUnreadFolder;
          var unreadTxt = colors.textUnreadFolder;
          var unreadIcon = colors.iconUnreadFolder;

          folder.style.setProperty('background-color', unreadBg, 'important');
          folder.style.setProperty('background', unreadBg, 'important');
          folder.style.setProperty('border', '1px solid ' + unreadBorder, 'important');
          folder.style.removeProperty('border-left');
          folder.style.setProperty('border-radius', '8px', 'important');

          var innerElementsUnread = folder.querySelectorAll('.md-button, .md-no-style, .md-list-item-inner, .md-list-item-text');
          for (var ieu = 0; ieu < innerElementsUnread.length; ieu++) {
            innerElementsUnread[ieu].style.setProperty('background', 'transparent', 'important');
            innerElementsUnread[ieu].style.setProperty('background-color', 'transparent', 'important');
          }

          var uKids = folder.querySelectorAll('*');
          for (var uk = 0; uk < uKids.length; uk++) {
            var uNode = uKids[uk];
            if (uNode.tagName === 'MD-ICON' || uNode.tagName === 'SVG' || uNode.tagName === 'PATH') {
              uNode.style.setProperty('color', uNode.closest('md-sidenav') && colors.isDark ? '#ffffff' : '#041e49', 'important');
              uNode.style.setProperty('fill', uNode.closest('md-sidenav') && colors.isDark ? '#ffffff' : '#041e49', 'important');
              uNode.style.setProperty('opacity', '1', 'important');
              uNode.style.setProperty('visibility', 'visible', 'important');
            } else if (!uNode.classList.contains('md-button') && !uNode.classList.contains('md-no-style') && !uNode.classList.contains('md-list-item-inner')) {
              uNode.style.setProperty('color', unreadTxt, 'important');
              uNode.style.setProperty('-webkit-text-fill-color', unreadTxt, 'important');
              uNode.style.setProperty('font-weight', '700', 'important');
              uNode.style.setProperty('opacity', '1', 'important');
              uNode.style.setProperty('visibility', 'visible', 'important');
            }
          }
        } else {
          // NORMÁL MAPPA VISSZAÁLLÍTÁSA
          folder.style.removeProperty('background-color');
          folder.style.removeProperty('background');
          folder.style.removeProperty('border');
          folder.style.removeProperty('border-left');

          var innerElementsNormal = folder.querySelectorAll('.md-button, .md-no-style, .md-list-item-inner, .md-list-item-text');
          for (var ien = 0; ien < innerElementsNormal.length; ien++) {
            innerElementsNormal[ien].style.removeProperty('background-color');
            innerElementsNormal[ien].style.removeProperty('background');
          }

          var normalKids = folder.querySelectorAll('*');
          for (var nk = 0; nk < normalKids.length; nk++) {
            var nChild = normalKids[nk];
            if (nChild.tagName === 'MD-ICON' || nChild.tagName === 'SVG' || nChild.tagName === 'PATH') {
              if (colors.isDark) {
                nChild.style.setProperty('color', '#ffffff', 'important');
                nChild.style.setProperty('fill', '#ffffff', 'important');
              } else {
                nChild.style.setProperty('color', '#041e49', 'important');
                nChild.style.setProperty('fill', '#041e49', 'important');
              }
              nChild.style.setProperty('opacity', '1', 'important');
              nChild.style.setProperty('visibility', 'visible', 'important');
            } else if (!nChild.classList.contains('md-button') && !nChild.classList.contains('md-no-style') && !nChild.classList.contains('md-list-item-inner')) {
              nChild.style.removeProperty('background-color');
              if (colors.isDark) {
                nChild.style.setProperty('color', '#d3dbe2', 'important');
                nChild.style.setProperty('-webkit-text-fill-color', '#d3dbe2', 'important');
                nChild.style.removeProperty('font-weight');
              } else {
                nChild.style.setProperty('color', '#041e49', 'important');
                nChild.style.setProperty('-webkit-text-fill-color', '#041e49', 'important');
                nChild.style.removeProperty('font-weight');
              }
            }
          }
        }
      }

      // 3. Globális ikonok kényszerítése
      var allIcons = document.querySelectorAll('md-icon');
      for (var ai = 0; ai < allIcons.length; ai++) {
        var ic = allIcons[ai];
        if (ic.closest && ic.closest('.sg-calendar-event, button.md-fab')) continue;
        ic.style.setProperty('color', targetIconColor, 'important');
        ic.style.setProperty('fill', targetIconColor, 'important');
      }
    }

    $timeout(function() {
      injectPersistentStyle();
      injectThemeToggleButton();
      enforceUniformCardBaseline();
      syncActiveItemsAndFolders();
    }, 100);

    $interval(function() {
      injectPersistentStyle();
      injectThemeToggleButton();
      enforceUniformCardBaseline();
      syncActiveItemsAndFolders();
    }, 200);
  }
})();

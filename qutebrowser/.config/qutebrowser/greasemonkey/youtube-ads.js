// ==UserScript==
// @name         Youtube Ad Skip
// @version      0.2.5
// @description  Get rid of Youtube ads
// @author       Adcott
// @match        *://*.youtube.com/*
// ==/UserScript==

GM_addStyle(`
#player-ads, .adDisplay, .ad-container, .ytd-display-ad-renderer, .video-ads,
ytd-rich-item-renderer:has(ytd-ad-slot-renderer), ytd-ad-slot-renderer,
#masthead-ad, *[class^="ytd-ad-"], #panels.ytd-watch-flexy {
    display: none !important;
}`);

new MutationObserver(mutations => {
    for (const mutation of mutations) {
        mutation.addedNodes.forEach(node => {
            if (node.nodeType !== 1 ||
                !node.classList.contains('ytp-ad-persistent-progress-bar-container')) return;
            const video = document.querySelector('.html5-main-video');
            if (video) video.currentTime = video.duration;
        });
    }
}).observe(document.body, {childList:true, subtree:true});

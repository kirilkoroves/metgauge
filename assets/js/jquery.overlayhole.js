/* overlayhole - An Overlay with a Hole as a JQuery Plugin!
 * Version 1.0.1
 * 
 * Copyright 2017 Felipe Dias
 * 
 * This file is part of overlayhole.
 * 
 * overlayhole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * overlayhole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with overlayhole.  If not, see <http://www.gnu.org/licenses/>.
 */

(function($) {
    $.overlayhole = (function() {
		var _settings = {
			padding : 4,
			recalcOnShow : false
		};
		var _targets = [];
		var _rect = null;
		
		
		function _initialized() {
			return $("#overlayhole-container").length > 0;
		};
		
		
		function _init(options) {
			if (_initialized()) return;
			
			_settings = $.extend(_settings, options);
			
			$("<style>")
				.prop("type", "text/css")
				.html("\
					.overlayhole-noselect {\
						-webkit-user-select: none;\
						user-select: none;\
						pointer-events: none\
					}\
					.overlayhole-target {\
						-webkit-user-select: auto !important;\
						user-select: auto !important;\
						pointer-events: auto !important\
					}\
					.overlayhole-target * {\
						-webkit-user-select: auto !important;\
						user-select: auto !important;\
						pointer-events: auto !important\
					}"
				).appendTo("head");
			
			var container = $("<div>")
				.attr("id", "overlayhole-container")
				.attr("class", "overlayhole-object")
				.css({
					display : "none",
					position : "absolute",
					left : "0px",
					top : "0px",
					zIndex: "999999 !important",
					border: "none",
					margin: "0px",
					padding: "0px"
				});
			
			for (var i=0; i<4; i++) {
				var overlay = $("<div>")
					.attr("class", "overlayhole-object")
					.css({
						display: "inline-block",
						position: "absolute",
						backgroundColor:  "rgba(0, 0, 0, .8)",
						border: "none",
						margin: "0px",
						padding: "0px"
					});
				container.append(overlay);
			}
			
			$("body").append(container);
			$(window).resize(_calcRects);
		}
		
		function _markTargets() {
			$(".overlayhole-target").removeClass("overlayhole-target");
			_targets.forEach( node => $(node).addClass("overlayhole-target") );
		}
		
		function _calcRects() {
			var rects = _targets.filter( node => $(node).is(":visible") ).map( node => node.getBoundingClientRect() );
			
			_rect = {
				top : Math.min.apply( null, rects.map(rect => rect.top) ),
				left : Math.min.apply( null, rects.map(rect => rect.left) ),
				bottom : Math.max.apply( null, rects.map(rect => rect.bottom) ),
				right : Math.max.apply( null, rects.map(rect => rect.right) ),
			};
			
			_rect.width = _rect.right - _rect.left;
			_rect.height = _rect.bottom - _rect.top;
			
			_calcOverlay();
		}
		
		function _calcOverlay() {
			var overlayTop = $("#overlayhole-container > :first-child");
			var overlayLeft = $("#overlayhole-container > :nth-child(2)");
			var overlayRight = $("#overlayhole-container > :nth-child(3)");
			var overlayBottom = $("#overlayhole-container > :last-child");

			var body = document.body;
			var html = document.documentElement;
			var height = Math.max( body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight );
			var width = Math.max( body.scrollWidth, body.offsetWidth, html.clientWidth, html.scrollWidth, html.offsetWidth );
			
			overlayTop.css({
				top : "0px",
				left : "0px",
				width : Math.max(width,0)+"px",
				height : Math.max(_rect.top+scrollY-_settings.padding,0)+"px"
			});

			overlayBottom.css({
				top : _rect.bottom+scrollY+_settings.padding+"px",
				left : "0px",
				width : Math.max(width,0)+"px",
				height : Math.max(height-_rect.bottom-scrollY-_settings.padding,0)+"px"
			});

			overlayLeft.css({
				top : _rect.top+scrollY-_settings.padding+"px",
				left : "0px",
				width : Math.max(_rect.left+scrollX-_settings.padding,0)+"px",
				height : Math.max(_rect.height+2*_settings.padding,0)+"px"
			});

			overlayRight.css({
				top : _rect.top+scrollY-_settings.padding+"px",
				left : _rect.right+scrollX+_settings.padding+"px",
				width : Math.max(width-_rect.right-scrollX-_settings.padding,0)+"px",
				height : Math.max(_rect.height+2*_settings.padding,0)+"px"
			});
		}
		
		return {
			init : _init,
			
			show : function() {
				if (!_initialized()) {
					throw "Not initialized!";
				}
				
				if (self.recalcOnShow) {
					self.calcRects();
				}
				$("body *").not(".overlayhole-object,.overlayhole-target").addClass("overlayhole-noselect");
				$("#overlayhole-container").css("display", "inline-block");
			},
			
			hide : function() {
				if (!_initialized()) {
					throw "Not initialized!";
				}
				
				$("#overlayhole-container").css("display", "none");
				$(".overlayhole-noselect").removeClass("overlayhole-noselect");
			},
			
			set targets(list) {
				if (!_initialized()) {
					throw "Not initialized!";
				}
				
				if (!(list instanceof Array)) {
					throw "The setTargets method should receive an array!";
				}
				
				_targets = list.filter( target => target instanceof HTMLElement);
				
				if (_targets.length > 0) {
					_calcRects();
					_markTargets();
				}
			},
			
			get rect() {
				return _rect === null ? null : { top : _rect.top, left : _rect.left, width : _rect.width, height : _rect.height };
			}
		}
	})();
}(jQuery));

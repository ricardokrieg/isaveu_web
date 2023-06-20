!function(e) {
  "use strict";
  function s(s) {
    s.each(function() {
          var s=e(this), i=s.data("delay"), o=s.data("duration"), a="animated "+s.data("animation");
          s.css( {
                "animation-delay": i, "-webkit-animation-delay": i, "animation-duration": o, "-webkit-animation-duration": o
              }
          ), s.addClass(a).one("webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend", function() {
                s.removeClass(a)
              }
          )
        }
    )
  }
  e(window).on("load", function() {
        e("#body").each(function() {
              var s=e(".header"), i=s.find(".navbar"), o=(i.find(".site-logo"), i.find(".navigation")), a= {
                    nav_top: o.css("margin-top")
                  }
              ;
              e(window).scroll(function() {
                    i.hasClass("navbar-sticky")&&(e(this).scrollTop()<=100||e(this).width()<=750)?(i.removeClass("navbar-sticky").appendTo(s), o.animate( {
                          "margin-top": a.nav_top
                        }
                        , {
                          duration:100, queue:!1, complete:function() {
                            s.css("height", "auto")
                          }
                        }
                    )):!i.hasClass("navbar-sticky")&&e(this).width()>750&&e(this).scrollTop()>400&&(s.css("height", s.height()), i.css( {
                          opacity: "0"
                        }
                    ).addClass("navbar-sticky"), i.appendTo(e("body")).animate( {
                          opacity: 1
                        }
                    ), o.css( {
                          "margin-top": "0px"
                        }
                    ))
                  }
              )
            }
        ), e(window).trigger("resize"), e(window).trigger("scroll")
      }
  );
  var o=e(".mobile-sticky-header-overlay"),
      a=e(".navbar-collapse"),
      t=e(".icon-toggle");
  e(".navbar-toggler").on("click", function(s) {
        e(this).css("visibility", "hidden").toggleClass("clicked"), e(".navbar-brand").toggleClass("shade"), t.toggleClass("active"), o.toggleClass("active"), a.toggleClass("show"), e(this).css("visibility", "visible")
      }
  ),
      e(".navbar a.dropdown-toggle").on("click", function(s) {
            var i=e(this).parent().parent();
            if(!i.hasClass("navbar-nav")) {
              var o=e(this).parent(), a=parseInt(i.css("height").replace("px", ""), 10)/2, t=parseInt(i.css("width").replace("px", ""), 10)-10;
              return o.hasClass("show")?o.removeClass("show"): o.addClass("show"), e(this).next().css("top", a+"px"), e(this).next().css("left", t+"px"), !1
            }
          }
      ),
  e(".navbar").width()>768&&e(".navbar-nav .dropdown").hover(function() {
        e(this).addClass("show")
      }
      , function() {
        e(this).removeClass("show")
      }
  );
  e("#banner-slider").on("init", function(i, o) {
        s(e("div.item:first-child").find("[data-animation]"))
      }
  ),
  e("#banner-slider").on("beforeChange", function(i, o, a, t) {
        s(e('div.item[data-slick-index="'+t+'"]').find("[data-animation]"))
      }
  ),
  e("#banner-slider").slick( {
        autoplay:!0, autoplaySpeed:3e3, dots:!0, arrows:!1, fade:!0, slidesToShow:1, slidesToScroll:1, responsive:[ {
          breakpoint:1024, settings: {
            dots: !0
          }
        }
          , {
            breakpoint:768, settings: {
              dots: !1, arrows: !1, autoplay: !0
            }
          }
          , {
            breakpoint:480, settings: {
              dots: !1
            }
          }
        ]
      }
  );
  e(".select-drop").selectbox();
}

(jQuery);

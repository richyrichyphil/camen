/* -----------------------------------------------
					Js Main
--------------------------------------------------
    Template Name: NoonPost. - Personal Blog HTML Template
--------------------------------------------------

Table of Content

	  . Preloader
    . Navigation
    . Search
    . Back-top
    . theiaStickySidebar
    . Masonry
    . Slider one
    . Slider two
    . Slider three
    . Slider four
    . Slider five
    . Slider six
    
----------------------------------- */

    /* -----------------------------------
            Preloader
    ----------------------------------- */
    
    function loading() {
      $('.loading').delay(500).fadeOut(500);
    }
    loading()


    /* -----------------------------------
            Navigation
    ----------------------------------- */
      const navbarToggler = document.querySelector('.navbar-toggler');
      const navbarCollapse = document.querySelector('.navbar-collapse');

      navbarToggler.addEventListener('click', function() {
          navbarCollapse.collapse('show');
    });

     /* -----------------------------------
           Search
      ----------------------------------- */
      function handleSearchIconClick() {
        const searchBox = document.querySelector('.search__box');
        searchBox.classList.add('search__box--open');
      }

      function handleSearchBoxCloseClick() {
        const searchBox = document.querySelector('.search__box');
        searchBox.classList.remove('search__box--open');
      }

      document.querySelector('.search-icon').addEventListener('click', handleSearchIconClick);
      document.querySelector('.search__box-btn-close').addEventListener('click', handleSearchBoxCloseClick);

      /* -----------------------------------
           Back-top
      ----------------------------------- */
        const backTopBtn = document.querySelector(".btn-back-top");
        window.addEventListener("scroll", function() {
          console.log(window.scrollY )
          if (window.scrollY > 300) {
            backTopBtn.classList.add("show");
          } else {
            backTopBtn.classList.remove("show");
          }
        });

        backTopBtn.addEventListener("click", function(e) {
          e.preventDefault(); 
          window.scrollTo({
            top: 0,
            behavior: "smooth"
          });
        });


    /* -----------------------------------
       theiaStickySidebar
    -----------------------------------*/
  
    $('.side-content,.side-sidebar').theiaStickySidebar({
         additionalMarginTop: 0
    });

   /* -----------------------------------
           Masonry
    ----------------------------------- */
    $(window).on("load resize", function () {
        $(".masonry-items").masonry({
          itemSelector: ".masonry-item",
          columnWidth: ".masonry-item",
        });
    });
   
     /* -----------------------------------
          slider one
    -----------------------------------*/
      var swiper = new Swiper(".slider--one .mySwiper", {
        spaceBetween: 0,
        centeredSlides: true,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
        pagination: {
          el: ".swiper-pagination",
          clickable: true,
        },
        navigation: {
          nextEl: ".swiper-button-next",
          prevEl: ".swiper-button-prev",
        },
      });


    /* -----------------------------------
          slider-two
    -----------------------------------*/
      var swiperBottom = new Swiper(".slider--two .slider__bottom", {
        spaceBetween: 0,
        slidesPerView: 4,
        freeMode: true,
        watchSlidesProgress: true,
        autoplay: {
        delay: 2500,
        disableOnInteraction: false,
      },
    
      });
      
      var swiper = new Swiper(".slider--two .slider__top", {
        spaceBetween: 0,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
        navigation: {
          nextEl: ".swiper-button-next",
          prevEl: ".swiper-button-prev",
        },
        thumbs: {
          swiper: swiperBottom,
        },

      });

    /* -----------------------------------
          slider-three
    -----------------------------------*/
      var swiper = new Swiper(".slider--three", {
        slidesPerView: 3,
        spaceBetween: 30,
        loop: true,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
        breakpoints: {
          0: {
            slidesPerView: 1,
            spaceBetween: 10,
          },
          640: {
            slidesPerView: 1,
            spaceBetween: 30,
          },
          1050: {
            slidesPerView: 2,
            spaceBetween: 30,
          },
          1350: {
            slidesPerView: 3,
            spaceBetween: 30,
          },
          1800: {
            slidesPerView: 4,
            spaceBetween: 30,
          },
        },
        navigation: {
          nextEl: ".swiper-button-next",
          prevEl: ".swiper-button-prev",
        },
      });


    /* -----------------------------------
            slider-Four
    -----------------------------------*/
      var swiper = new Swiper(".slider--four .mySwiper", {
        slidesPerView: 1,
        spaceBetween: 1,
        loop: true,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
        grabCursor: true,    
        keyboard: {
          enabled: true,
        },
      
        breakpoints: {
          0: {
            slidesPerView: 1,
          
          },
          769: {
            slidesPerView: 2,
        
          },
        
          1000: {
            slidesPerView: 3,
          
          },
          1400: {
            slidesPerView: 4,
          
          },
        },
      
      });

    /* -----------------------------------
          slider-five
    -----------------------------------*/
    var swiper = new Swiper(".slider--five", {
        slidesPerView: 1,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
        navigation: {
          nextEl: ".swiper-button-next",
          prevEl: ".swiper-button-prev",
        },
      });

    /* -----------------------------------
          slider-six
    -----------------------------------*/
    var swiper = new Swiper(".slider--six", {
        slidesPerView: 4,
        spaceBetween: 30,
        freeMode: true,
        loop: true,
        autoplay: {
          delay: 2500,
          disableOnInteraction: false,
        },
        breakpoints: {
          0: {
            slidesPerView: 1,
            spaceBetween: 15,
          },
          640: {
            slidesPerView: 1,
            spaceBetween: 30,
          },
          1050: {
            slidesPerView: 2,
            spaceBetween: 30,
          },
          1350: {
            slidesPerView: 3,
            spaceBetween: 30,
          },
          1400: {
            slidesPerView: 4,
            spaceBetween: 30,
          },
        },
        pagination: {
          el: ".swiper-pagination",
          clickable: true,
        },
      });
  

'use strict';

    var currentPage = 1;
    var numberOfPages = 0;
    var authorId = 0;


    function loadResources() {
        fetchAuthorInfo(authorId);
        fetchDataByPage(1);
    }


    function fetchDataByPage(page) {

        var token = keycloak.token;
        var _API_BASE_URL_ = 'http://localhost:3000/author/'+authorId+'/publication';
        var urlToCall = _API_BASE_URL_ +'?' +buildParamList(page);

       // alert(urlToCall);

        $.ajax({
            url: urlToCall,
            type: 'GET',
            headers: {
                'Authorization': 'Bearer ' + token,  
                'Content-Type': 'application/json' 
            },             
            success: function (response) {
                displayPapers(response.Papers.data, response.Papers.page);  
                hidePreloader("#preloaderTable","#loaderTable");              
            },
            error: function (xhr, status, error) {

                displayError(xhr, status, error);
                hidePreloader("#preloaderTable","#loaderTable");
            }
        });
    }   
    
    
    function fetchAuthorInfo(authorId) {
        
        var token = keycloak.token;       
        var _API_BASE_URL_ = 'http://localhost:3000/author/';
        var urlToCall = _API_BASE_URL_ + authorId;

       // alert(urlToCall);

        $.ajax({
            url: urlToCall,
            type: 'GET',
            async: false,
            headers: {
                'Authorization': 'Bearer ' + token,  
                'Content-Type': 'application/json' 
            },            
            success: function (response) {
                displayAuthor(response.Author);                
            },
            error: function (xhr, status, error) {

                displayError(xhr, status, error);
            }
        });
    }  
    
    function displayAuthor(author) {
        $('#author-name').text(author.name);
        $('#author-pc').text(author.paper_count);
        $('#author-cc').text(author.citation_count);
        $('#author-sc-page').html('<a href="'+author.url+'"'+'>Go to Semantic Scholar Author Page</a>');

        if (author.home_page === null) {
            $('#author-home-page').text("-");    
        }
        else {
            $('#author-home-page').html('<a href="'+author.home_page+'"'+'>Home Page</a>');       
        }

        numberOfPages = Math.ceil(author.paper_count / 10);
        //alert(numberOfPages);

    }

    function displayPapers(data, currentPage) {
        $('#paper-body').empty();
        $("#paper-table").show();

        if (numberOfPages <=1)
        {
            $('#next-page').prop('disabled', true);
            $('#prev-page').prop('disabled', true);
        }

        if (currentPage == 1 && numberOfPages >1)
        {
            $('#next-page').prop('disabled', false);
            $('#prev-page').prop('disabled', true);
        }

        var paperTable = '';
        $.each(data, function (index, paper) {
            paperTable += '<tr>';
            if (paper.doi === null) {
                paperTable += '<td>-</td>';
            }
            else {
                paperTable += '<td><a href="./citations-detail.html?paperId=' + paper.doi +'&authorId='+authorId+'">'+ paper.doi+'</a></td>';
            }

            paperTable += '<td title="' + paper.title + '">' + paper.title.substring(0, 50);
            
            if (paper.title.length > 50) {
                paperTable += '...</td>'; 
            }
            else {
                paperTable += '</td>';
            }

            paperTable += '<td>' + paper.year + '</td>';

            paperTable += '<td title="' + paper.other_authors + '">' + paper.other_authors.substring(0, 30);

            if (paper.other_authors.length > 50) {
                paperTable += '...</td>'; 
            }
            else {
                paperTable += '</td>';
            }

            paperTable += '<td>' + paper.citation_count + '</td>';
            paperTable += '</tr>';
        });
        $('#paper-body').html(paperTable);
        $('#next-page').show();
        $('#prev-page').show();
        $('#page-number').text('Page:'+currentPage);
        $('#pagination-info').text('');
    }      
    
    function displayNoPapers() {
        $('#pagination-info').text('No Papers Found');
        $('#sliderrow').empty();
        $('#page-number').text('');
    }

    function displayError(xhr, status, error) {
        showNotification('Error calling API status: '+xhr.status+' Error: '+xhr.statusText);
        $('#sliderrow').empty();
        $('#page-number').text('');
    }   
    

    function buildParamList (page) {

        var params = {
            page: page
        }

        var queryString = Object.keys(params).map(function (key) {
            return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
        }).join('&');

        return queryString;

    }

    function showPreloader(preloader,loader) {
        // Mostra il preloader
        $(preloader).fadeIn("fast");
        $(loader).fadeIn("fast");
    }

    function hidePreloader(preloader,loader) {
        // Nasconde il preloader
        $(loader).fadeOut();
        $(preloader).delay(200).fadeOut("slow");
    }

  // Funzione per mostrare la notifica
  function showNotification(message) {
    $('#notification-text').text(message);
    $('#notification').removeClass('hidden');
    }

    // Funzione per nascondere la notifica
    function hideNotification() {
        $('#notification').addClass('hidden');
    }

    // Gestione del clic sul pulsante di chiusura
    $('#close-btn').on('click', function() {
        hideNotification();
    });    

    $(document).ready(function () {


        hidePreloader("#preloaderTable","#loaderTable");
        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        authorId = urlParams.get('authorId');

        // Event listener per il bottone previous page
       $('#prev-page').click(function () {
            showPreloader("#preloaderTable","#loaderTable");   
            if (currentPage > 1) {
                currentPage--;
                $('#next-page').prop('disabled', false);
                fetchDataByPage(currentPage);
            }

            if (currentPage==1) {
                $('#prev-page').prop('disabled', true);
            }
        });



        // Event listener per il bottone next page
        $('#next-page').click(function () {
            showPreloader("#preloaderTable","#loaderTable");                
            if (currentPage < numberOfPages) {
                currentPage++;
                $('#prev-page').prop('disabled', false);
                fetchDataByPage(currentPage);
            }

            if (currentPage == numberOfPages) {
                $('#next-page').prop('disabled', true);
            }

        });

        $('#next-page').hide();
        $('#prev-page').hide();
        $('#page-number').text('');
        $('.spinner-border').hide();
        $("#paper-table").hide();

        showPreloader("#preloaderTable","#loaderTable");    

 //       fetchAuthorInfo(authorId);
 //      fetchDataByPage(1);


    });


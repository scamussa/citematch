
'use strict';

    var currentPage = 1;
    var numberOfPages = 0;
    var authorId = 0;
    var paperId = ""


    function loadResources() {

        showPreloader("#preloaderTable","#loaderTable");
        fetchAuthorInfo(authorId);
        fetchPaperInfo(paperId);
        fetchCitations(paperId);

    }

    function changeImage(imgelement) {

        if (imgelement.src.includes("plus.png")) {
            imgelement.src = "img/accept.png"; 
            
        }  
    }
 
    function fetchAuthorInfo(authorId) {
        
        var token = keycloak.token;       
        var _API_BASE_URL_ = 'http://localhost:3000/author/';
        var urlToCall = _API_BASE_URL_ + authorId;

        //alert(urlToCall);

        $.ajax({
            url: urlToCall,
            type: 'GET',
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

    function fetchCitations(paperId) {

        var token = keycloak.token;
        var _API_BASE_URL_ = 'http://localhost:3000/paper/doi:'+paperId+'/citations';
        var urlToCall = _API_BASE_URL_ 

        //alert(urlToCall);

        $.ajax({
            url: urlToCall,
            type: 'GET',
            headers: {
                'Authorization': 'Bearer ' + token,  
                'Content-Type': 'application/json' 
            },             
            success: function (response) {
                displayCitations(response); 
                hidePreloader("#preloaderTable","#loaderTable");             
            },
            error: function (xhr, status, error) {
                displayError(xhr, status, error);
                hidePreloader("#preloaderTable","#loaderTable"); 
            }
        });
    }    

    function fetchPaperInfo(paperId) {
        
        var token = keycloak.token;        
        var _API_BASE_URL_ = 'http://localhost:3000/paper/';
        var urlToCall = _API_BASE_URL_ + paperId;

        //alert(urlToCall);

        $.ajax({
            url: urlToCall,
            type: 'GET',
            headers: {
                'Authorization': 'Bearer ' + token,  
                'Content-Type': 'application/json' 
            },            
            success: function (response) {
                displayPaper(response.Paper);              
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
        $('#author-sc-page').html('<a href="'+author.url+'"'+'>Semantic Scholar Author Page</a>');

        if (author.home_page === null) {
            $('#author-home-page').text("-");    
        }
        else {
            $('#author-home-page').html('<a href="'+author.home_page+'"'+'>Home Page</a>');       
        }
    }

    function displayPaper(paper) {
        $('#paper-doi').text(paper.doi);
        $('#paper-title').text(paper.title);
        $('#paper-year').text(paper.year);
        $('#paper-authors').text(paper.other_authors);
        $('#paper-citations').text(paper.citation_count);
        $('#paper-summary').text(paper.tldr);
    }   

    function displayCitations(data) {
        $('#paper-body').empty();
        $("#paper-table").show();

        var paperTable = '';

        $.each(data, function (index, paper) {
            paperTable += '<tr>';
            if (paper.doi === null) {
                paperTable += '<td>-</td>';
            }
            else {
                paperTable += '<td>' + paper.doi + '</td>';
            }

            paperTable += '<td title="' + paper.title + '">' + paper.title.substring(0, 50);
            
            if (paper.title.length > 50) {
                paperTable += '...</td>'; 
            }
            else {
                paperTable += '</td>';
            }
         
            paperTable += '<td>' + paper.year + '</td>';

            paperTable += '<td title="' + paper.authors + '">' + paper.authors.substring(0, 30);

            if (paper.authors.length > 50) {
                paperTable += '...</td>'; 
            }
            else {
                paperTable += '</td>';
            }


            if (paper.is_scholar_citation == "yes") {
                paperTable += '<td><img src="img/accept.png" width="20" height="20"/></td>';
            }
            else {
                paperTable += '<td><img src="img/close.png" width="20" height="20"/></td>';
            }

            if (paper.is_open_citation == "yes") {
                paperTable += '<td><img src="img/accept.png" width="20" height="20"/></td>';
            }
            else {
                paperTable += '<td><img src="img/close.png" width="20" height="20"/></td>';
            }          
            
            if (paper.can_be_added_to_scholar == "yes") {

                if (hasRole("cit-power-user")) {

                    paperTable += '<td><img src="img/plus.png" width="20" height="20" onclick="changeImage(this)"/></td>';
                }
                else {
                    paperTable += '<td><img src="img/plus_gray.png" width="20" height="20"/></td>'; 
                }
            }
            else {
                paperTable += '<td>-</td>';
            }                   
            paperTable += '</tr>';
        });
        $('#paper-body').html(paperTable);
        $('#pagination-info').text('');
    }      
    
    function displayNoPapers() {
        $('#pagination-info').text('No Papers Found');
        $('#sliderrow').empty();
    }

    function displayError(xhr, status, error) {

        showNotification('Error calling API status: '+xhr.status+' Error: '+xhr.statusText);
        $('#sliderrow').empty();
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

    $(document).ready(function () {


        var queryString = window.location.search;
        var urlParams = new URLSearchParams(queryString);
        paperId = urlParams.get('paperId');
        authorId = urlParams.get('authorId');

        $('#back-url').attr('href', '/citations/publication-list.html?authorId='+authorId);
        $('#back-url-ham').attr('href', '/citations/publication-list.html?authorId='+authorId);

        $("#paper-table").hide();

        hidePreloader("#preloaderTable","#loaderTable");
        showPreloader("#preloaderTable","#loaderTable");
    });


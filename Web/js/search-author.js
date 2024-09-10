
'use strict';

    var currentPage = 1;
    var numberOfPages = 0;

    function loadResources() {

    }
     
    
    function fetchDataByPage(page) {

        var token = keycloak.token;
        //alert(token);
        var _API_BASE_URL_ = 'http://localhost:3000/author/search';
        var urlToCall = _API_BASE_URL_ +'?' +buildParamListFromForm(page);

        //alert(urlToCall);

        $.ajax({
            url: urlToCall,
            type: 'GET',
            headers: {
                'Authorization': 'Bearer ' + token,  
                'Content-Type': 'application/json' 
            },            
            success: function (response) {
                numberOfPages = response.Authors.total_pages;
                if (numberOfPages == 0)  {
                    displayNoAuthors();
                    return;
                }
                displayAuthors(response.Authors.data, response.Authors.total, response.Authors.page,response.Authors.total_pages); 
                hidePreloader("#preloaderTable","#loaderTable");               
            },
            error: function (xhr, status, error) {

                displayError(xhr, status, error);
                hidePreloader("#preloaderTable","#loaderTable");
            }
        });
}

    function displayNoAuthors() {
        $('#pagination-info').text('No Authors Found');
        $('#sliderrow').empty();
        $('#page-number').text('');
        hidePreloader("#preloaderTable","#loaderTable");
    }

    function displayError(xhr, status, error) {
        showNotification('Error calling API status: '+xhr.status+' Error: '+xhr.statusText);
        //$('#pagination-info').text('Error calling API status: '+status+' Error: '+error);
        $('#sliderrow').empty();
        $('#page-number').text('');
    }

    function displayAuthors(data,totalElements,elementPerPage,totalPages) {
        $('#author-body').empty();
        $("#author-table").show();

        if (totalPages <=1)
        {
            $('#next-page').prop('disabled', true);
            $('#prev-page').prop('disabled', true);
        }

        if (currentPage == 1 && totalPages >1)
        {
            $('#next-page').prop('disabled', false);
            $('#prev-page').prop('disabled', true);
        }

        var authorTable = '';
        $.each(data, function (index, author) {
            authorTable += '<tr>';
            authorTable += '<td><a href="./publication-list.html?authorId=' + author.author_id +'">'+ author.author_id+'</a></td>';
            authorTable += '<td>' + author.name + '</td>';
            authorTable += '<td>' + author.paper_count + '</td>';
            authorTable += '<td>' + author.citation_count + '</td>';
            authorTable += '</tr>';
        });
        $('#author-body').html(authorTable);
        $('#next-page').show();
        $('#prev-page').show();
        $('#page-number').text('Page:'+currentPage);
        $('#pagination-info').text('');
}

    function buildParamListFromForm (page) {

        var params = {
            query: $('#author').val(),
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

        $('#prev-page').hide();

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
        $('#page-number').text('');
        $('.spinner-border').hide();
        $("#author-table").hide();
        $('#searchform').submit(function (event) {
            event.preventDefault();
            var currentPage = 1;
            var numberOfPages = 0;
            showPreloader("#preloaderTable","#loaderTable");           
            fetchDataByPage(1); 
        });
    });


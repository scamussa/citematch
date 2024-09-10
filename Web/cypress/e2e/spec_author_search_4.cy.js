

describe('Author Search', () => {
  it('should Next button be enabled and Previous is disabled when search result returns more than 11 authors and you are on the first page', () => {
    
    //Esegui il login su keycloack
    
    cy.origin('http://localhost:9090/', () => {   
      cy.visit('http://localhost:8080/citations/search-author.html'); 
      cy.get('[id=username]').click().type('cit-user-1');
      cy.get('[id=password]').click().type('cit-user-1');
      cy.get('#kc-login').click();
    });

    cy.intercept('GET', 'http://localhost:3000/author/search*').as('getAuthorSearch');

    // Torna nel contesto dell'applicativo principale
    cy.origin('http://localhost:8080/', () => {
     // Imposta i parametri di ricerca 
      cy.get('#author').type('alan');
      cy.get('#fetchDataBtn').click();
     // Attendi che l'API sia terminata prima di proseguire
      cy.wait('@getAuthorSearch');

     // Verifica che il bottone "Previous" sia disabilitato
      cy.get('#prev-page').should('be.disabled');

     // Verifica che il bottone "Next" sia disabilitato
      cy.get('#next-page').should('be.enabled');
    });
  });
});

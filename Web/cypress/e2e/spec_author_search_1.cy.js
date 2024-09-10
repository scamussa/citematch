

describe('Author Search', () => {
  it('should display search result when a valid author name is entered', () => {
    
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
      cy.get('#author').type('camussa');
      cy.get('#fetchDataBtn').click();
      // Attendi il completamento dell'API      
      cy.wait('@getAuthorSearch');
    // Verifica che la tabella contenga esattamente 5 righe nel tbody
      cy.get('#author-body tr').should('have.length', 5);
    });
  });
});

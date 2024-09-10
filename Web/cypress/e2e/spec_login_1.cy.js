

describe('Login', () => {
    it('should enter in the application when valid credentials are provieded to keycloack', () => {
      
      //Esegui il login su keycloack
      
      cy.origin('http://localhost:9090/', () => {   
        cy.visit('http://localhost:8080/citations/index.html');
        cy.get('[id=username]').click().type('cit-user-1');
        cy.get('[id=password]').click().type('cit-user-1');
        cy.get('#kc-login').click();
      });
  
      // Torna nel contesto dell'applicativo principale
      cy.origin('http://localhost:8080/', () => {
      // Verifica che sia visualizzata la pagine index.html
        cy.url().should('include', 'index.html');
      });
    });
  });
  
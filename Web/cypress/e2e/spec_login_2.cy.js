

describe('Login', () => {
    it('should have role cit-normal-user  when enter in the application as cit-user-1', () => {
      
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

     // Verifica che l'elemento con ID 'user-name' contenga il valore 'cit-user-1'
        cy.get('#user-name').should('have.text', 'cit-user-1');

     // Verifica che l'elemento con ID 'user-role' contenga il valore 'cit-normal-user'
        cy.get('#user-role').should('have.text', 'cit-normal-user');       


      });
    });
  });
  
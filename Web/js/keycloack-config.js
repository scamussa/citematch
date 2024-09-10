var keycloak = new Keycloak({
    url: 'http://localhost:9090/',
    realm: 'cit-realm',
    clientId: 'cit-client'
});

keycloak.init({ onLoad: 'login-required'}).then(function(authenticated) {
    console.log('Authenticated');  

    var userInfo = keycloak.tokenParsed;
    var realmRoles = userInfo.realm_access.roles || [];
    var citRoles = realmRoles.filter(role => role.startsWith('cit-'));
    $('#user-role').text(citRoles);
    $('#user-name').text(userInfo.preferred_username);
    $('#user-role-hamb').text(citRoles);
    $('#user-name-hamb').text(userInfo.preferred_username);

    loadResources();


}).catch(function() {
    console.log('Error during Authentication');
    window.location.href = '/citations/401.html';
});

keycloak.onTokenExpired = function() {
    keycloak.updateToken(30).catch(() => {
        console.log('Failed to refresh token');
        keycloak.logout();
    });
};

function hasRole(role) {
    return keycloak.hasRealmRole(role);
}
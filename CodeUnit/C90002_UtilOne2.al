codeunit 90002 BCConnector
{
    var
        ClientIdTxt: Label 'ec975157-6ef0-405e-8d85-71571c79c756';
        ClientSecretTxt: Label 'lAF8Q~pLqhkQ47JfHY1A2xgZYphJyFJRwTXwzcO6';
        AadTenantIdTxt: Label '9e0bb323-0ae5-4ab5-baed-25b8c94cf882';
        AuthorityTxt: Label 'https://login.microsoftonline.com/9e0bb323-0ae5-4ab5-baed-25b8c94cf882/oauth2/v2.0/authorize';

        BCEnvironmentNameTxt: Label '';
        BCCompanyIdTxt: Label 'Juegos%20y%20Maquinaria';
        BCBaseUrlTxt: Label 'https://api.businesscentral.dynamics.com/v2.0/9e0bb323-0ae5-4ab5-baed-25b8c94cf882/Production/ODataV4/Company(''Juegos%20y%20Maquinaria'')';


        AccessToken: Text;
        AccesTokenExpires: DateTime;
    //BCMS

    trigger OnRun()
    var
        Customers: Text;
        Items: Text;
    begin
        Customers := CallBusinessCentralAPI(BCEnvironmentNameTxt, BCCompanyIdTxt, 'Customerws');
        Message(Customers);
    end;

    procedure CallBusinessCentralAPI(BCEnvironmentName: Text; BCCompanyId: Text; Resource: Text) Result: Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
    begin
        if (AccessToken = '') or (AccesTokenExpires = 0DT) or (AccesTokenExpires > CurrentDateTime) then
            GetAccessToken(AadTenantIdTxt);
        Client.DefaultRequestHeaders.Add('Authorization', GetAuthenticationHeaderValue(AccessToken));
        Client.DefaultRequestHeaders.Add('Accept', 'application/json');



        Url := GetBCAPIUrl(BCEnvironmentName, BCCompanyId, Resource);
        if not Client.Get(Url, Response) then
            if Response.IsBlockedByEnvironment then
                Error('Request was blocked by environment')
            else
                Error('Request to Business Central failed\%', GetLastErrorText());
        if not Response.IsSuccessStatusCode then
            Error('Request to Business Central failed\%1 %2', Response.HttpStatusCode, Response.ReasonPhrase);
        Response.Content.ReadAs(Result);
    end;

    local procedure GetAccessToken(AadTenantId: Text)
    var
        OAuth2: Codeunit OAuth2;
        Scopes: List of [Text];
    begin
        Scopes.Add('https://api.businesscentral.dynamics.com/.default');
        if not OAuth2.AcquireTokenWithClientCredentials(ClientIdTxt, ClientSecretTxt, GetAuthorityUrl(AadTenantId), '', Scopes, AccessToken) then
            Error('Failed to retrieve access token\', GetLastErrorText());
        AccesTokenExpires := CurrentDateTime + (3599 * 1000);
    end;

    local procedure GetAuthenticationHeaderValue(AccessToken: Text) Value: Text;
    begin
        Value := StrSubstNo('Bearer %1', AccessToken);
    end;

    local procedure GetAuthorityUrl(AadTenantId: Text) Url: Text
    begin
        Url := AuthorityTxt;
        Url := Url.Replace('{AadTenantId}', AadTenantId);
    end;

    local procedure GetBCAPIUrl(BCEnvironmentName: Text; BCCOmpanyId: Text; Resource: Text) Url: Text;
    begin
        Url := BCBaseUrlTxt;
        Url := Url.Replace('{BCEnvironmentName}', BCEnvironmentName)
                  .Replace('{BCCompanyId}', BCCOmpanyId);
        Url := StrSubstNo('%1/%2', Url, Resource);
    end;
}
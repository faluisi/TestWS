codeunit 90009 BCConnectorold
{
    var

        // JYM
        ClientIdTxt: Label 'ec975157-6ef0-405e-8d85-71571c79c756';
        ClientSecretTxt: Label '3Mr8Q~z9d5EWViI43iBNnEtfXfT0TFd0bVyOHc8I';
        AadTenantIdTxt: Label '9e0bb323-0ae5-4ab5-baed-25b8c94cf882';
        AuthorityTxt: Label 'https://login.microsoftonline.com/9e0bb323-0ae5-4ab5-baed-25b8c94cf882/oauth2/v2.0/authorize';

        BCEnvironmentNameTxt: Label 'Production';
        //BCCompanyIdTxt: Label 'e00255ce-1638-ec11-a458-00224850fb25';
        BCCompanyIdTxt: label 'Juegos%20y%20Maquinaria';
        BCBaseUrlTxt: Label 'https://api.businesscentral.dynamics.com/v2.0/9e0bb323-0ae5-4ab5-baed-25b8c94cf882/{BCEnvironmentName}/ODataV4/Company(''Juegos%20y%20Maquinaria'')';

        AccessToken: Text;
        AccesTokenExpires: DateTime;
    // JYM

    //BCMS
    // ClientIdTxt: Label '0cd876e6-7b64-4807-824c-5590c66c5c73';
    // ClientSecretTxt: Label 'vlP8Q~aM5Vhk63NxUHDtQQzh_aQpJqbO96T6Jc4r';
    // AadTenantIdTxt: Label '4b682a42-1cb3-475f-9505-e2ae1971b156';

    // AuthorityTxt: Label 'https://login.microsoftonline.com/4b682a42-1cb3-475f-9505-e2ae1971b156/oauth2/v2.0/authorize';
    // BCEnvironmentNameTxt: Label 'Live220';
    // BCCompanyIdTxt: Label 'a63a2877-a6bb-4eb8-9414-d629ed8bcd7f';
    // //BCBaseUrlTxt: Label 'https://dynamics-bc.com:7146/Live220/api/v2.0/companies(a63a2877-a6bb-4eb8-9414-d629ed8bcd7f)';
    // BCBaseUrlTxt: Label 'https://dynamics-bc.com:7146/Live220/ODataV4/Company(''Drako%20Ltd'')';

    // AccessToken: Text;
    // AccesTokenExpires: DateTime;
    //BCMS

    trigger OnRun()
    var
        Customers: Text;
        Items: Text;
    begin
        Customers := CallBusinessCentralAPI(BCEnvironmentNameTxt, BCCompanyIdTxt, 'CustOpWS');
        //Items := CallBusinessCentralAPI(BCEnvironmentNameTxt, BCCompanyIdTxt, 'SiteWS');
        Message(Customers);
        //Message(Items);
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

        Scopes.Add('https://api.businesscentral.dynamics.com/.default'); // JYM
        //Scopes.Add('0cd876e6-7b64-4807-824c-5590c66c5c73/accessbc'); //BCMS
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
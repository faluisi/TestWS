codeunit 90008 BCConnector1
{
    var
        ClientIdTxt: Label '4f5781a2-233f-4013-a5d2-******';
        ClientSecretTxt: Label 'T1j8Q~EwnVbAIR8RQXCwhZxZ-*******';
        AadTenantIdTxt: Label 'b4e1986f-b1d6-4197-91ae-********';
        AuthorityTxt: Label 'https://login.microsoftonline.com/b4e1986f-b1d6-4197-91ae-********oauth2/v2.0/authorize';
        BCEnvironmentNameTxt: Label 'test1';
        BCCompanyIdTxt: Label 'OneTech';
        BCBaseUrlTxt: Label 'https://api.businesscentral.dynamics.com/v2.0/b4e1986f-b1d6-4197-91ae--********/test1/ODataV4/Company(''OneTech'')';
        AccessToken: Text;
        AccesTokenExpires: DateTime;
    //BCMS

    trigger OnRun()
    var
        Customers: Text;
        Items: Text;
    begin
        Customers := CallBusinessCentralAPI(BCEnvironmentNameTxt, BCCompanyIdTxt, 'custoemrs');
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
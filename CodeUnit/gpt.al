codeunit 90005 HttpClientExample
{
    procedure GetData()
    var

        CustomerData: Text;
    begin
        GetAccessToken();
        HttpClient.Get('https://api.businesscentral.dynamics.com/v2.0/9e0bb323-0ae5-4ab5-baed-25b8c94cf882/Production/ODataV4/Company(''Juegos%20y%20Maquinaria'')/SiteWS', Response);
        if Response.HttpStatusCode = 200 then begin
            Response.Content.ReadAs(CustomerData);
            // Process the CustomerData as needed
            message(CustomerData);
        end
        else begin
            // Handle the error
            Error('Error ' + Format(Response.HttpStatusCode) + ': ' + Response.ReasonPhrase);
        end;
    end;

    procedure GetAccessToken()
    var

        Response: HttpResponseMessage;
        TokenData: Text;
        TokenResponse: Text;
        tokendatah: HttpContent;

    begin


        TokenData := 'grant_type=client_credentials&client_id=' + ClientId + '&client_secret=' + ClientSecret + '&scope=' + Scope;
        tokendatah.ReadAs(TokenData);
        HttpClient.Post(TokenEndpoint, TokenDatah, Response);
        if Response.httpStatusCode = 200 then begin
            Response.Content.ReadAs(TokenResponse);
            AccessToken := TokenResponse;
        end
        else begin
            Error('Error ' + Format(Response.httpStatusCode) + ': ' + Response.ReasonPhrase);
        end;
    end;

    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        TokenEndpoint: label 'https://login.microsoftonline.com/9e0bb323-0ae5-4ab5-baed-25b8c94cf882/oauth2/token';
        ClientId: label 'ec975157-6ef0-405e-8d85-71571c79c756';
        ClientSecret: label '3Mr8Q~z9d5EWViI43iBNnEtfXfT0TFd0bVyOHc8I';
        Scope: Label 'https://api.businesscentral.dynamics.com/.default';
        Resource: Label 'https://api.businesscentral.dynamics.com';
        AccessToken: Text;

}

// codeunit 90002 HttpClientExample
// {

//     procedure GetAccessToken()
//     var
//         HttpClient: HttpClient;
//         Response: HttpResponseMessage;
//         TokenData: Text;
//         TokenResponse: Dictionary of [Text, Variant];
//     begin
//         TokenData := 'grant_type=client_credentials&client_id=' + ClientId + '&client_secret=' + ClientSecret + '&scope=' + Scope;

//         HttpClient.Post(TokenEndpoint, TokenData, Response);
//         if Response.StatusCode = 200 then begin
//             Response.Content.ReadAs(TokenResponse);
//             AccessToken := TokenResponse.Get('access_token');
//         end
//         else begin
//             Error('Error ' + Format(Response.StatusCode) + ': ' + Response.ReasonPhrase);
//         end;
//     end;

//     procedure GetCustomerData()
//     var
//         HttpClient: HttpClient;
//         Response: HttpResponseMessage;
//         CustomerData: Text;
//     begin
//         GetAccessToken();
//         HttpClient.Get('https://api.businesscentral.dynamics.com/v2.0/<tenant_id>/sandbox/companies(<company_id>)/customers', Response);
//         if Response.StatusCode = 200 then begin
//             Response.Content.ReadAs(CustomerData);
//             // Process the CustomerData as needed
//         end
//         else begin
//             Error('Error ' + Format(Response.StatusCode) + ': ' + Response.ReasonPhrase);
//         end;
//     end;



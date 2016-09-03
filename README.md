# GAuth

GAuth is small framework that makes authentication to Google Services easier by properly implementing the OAuth authentication flow described in [Google's Developers website](https://developers.google.com/identity/protocols/OAuth2InstalledApp).

GAuth is not about to provide yet another Swift OAuth client but to easily integrate Google Authentication with your exisiting OAuth library. 

# How to use it

Integrate GAuth by making your OAuthClient (OAuthSwift, SwiftyOAuth) conform to `GoogleAuthenticatorOAuthClient`.

Finally authorize your device via the `GoogleAuthenticatorClient` by passing the proper OAuth client. 

See the example project (using [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift), [SwiftyOAuth](https://github.com/delba/SwiftyOAuth) to see how it works in details.

# Support for Limited Input Device Applications

GAuth cares to support all platforms therefore it also implements the [Device Authentication Flow](https://tools.ietf.org/html/draft-ietf-oauth-v2-01#section-3.5.3) for devices that can not support the standard authorization flows (i.e. tvOS which does not include WebKit framework). 

# Roadmap

- [] Include code example
- [] Add more Google Service Scope.
- [] Added Travis CI/Circle CI to the repo
- [] Add support for Swift 3

# Credits

GAuth's primary author is Fabio Milano, iOS Engineer at [Touchwonders](http://www.touchwonders.com).

GAuth was inspired from the need of having a simple framework that could support all type of platforms and easily integrate with an existing OAuth client.

# License

GAuth is available under the MIT license. See the LICENSE file for more info.
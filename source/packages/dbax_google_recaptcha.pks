CREATE OR REPLACE PACKAGE dbax_google_recaptcha
AS
   /**
   * Receives the user's response from reCAPTCHA widget and verify against google api.
   *
   * @param  p_recaptcha_response     The value of 'g-recaptcha-response'.
   * @param  p_secret_key             The key for communication between your site and Google. Be sure to keep it a secret.
   * @param  p_api_url                The Google recaptcha API URL
   * @return                          true | false
   */
   FUNCTION siteverify (p_recaptcha_response   IN VARCHAR2
                      , p_secret_key           IN VARCHAR2
                      , p_api_url              IN VARCHAR2 DEFAULT 'https://www.google.com/recaptcha/api/siteverify' )
      RETURN BOOLEAN;
END dbax_google_recaptcha;
/

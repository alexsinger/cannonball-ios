//
// Copyright (C) 2014 Twitter, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import TwitterKit
import DigitsKit
import Crashlytics

class SignInViewController: UIViewController, UIAlertViewDelegate {

    // MARK: Properties

    @IBOutlet weak var logoView: UIImageView!

    @IBOutlet weak var signInTwitterButton: UIButton!

    @IBOutlet weak var signInPhoneButton: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Color the logo.
        logoView.image = logoView.image?.withRenderingMode(.alwaysTemplate)
        logoView.tintColor = UIColor(red: 0, green: 167/255, blue: 155/255, alpha: 1)

        // Decorate the Sign In with Twitter and Phone buttons.
        let defaultColor = signInPhoneButton.titleLabel?.textColor
        decorateButton(signInTwitterButton, color: UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1))
        decorateButton(signInPhoneButton, color: defaultColor!)

        // Add custom image to the Sign In with Phone button.
        let image = UIImage(named: "Phone")?.withRenderingMode(.alwaysTemplate)
        signInPhoneButton.setImage(image, for: UIControlState())
    }

    fileprivate func navigateToMainAppScreen() {
        performSegue(withIdentifier: "ShowThemeChooser", sender: self)
    }

    // MARK: IBActions

    @IBAction func signInWithTwitter(_ sender: UIButton) {
        Twitter.sharedInstance().logIn { session, error in
            if session != nil {
                // Navigate to the main app screen to select a theme.
                self.navigateToMainAppScreen()

                // Tie crashes to a Twitter user ID and username in Crashlytics.
                Crashlytics.sharedInstance().setUserIdentifier(session!.userID)
                Crashlytics.sharedInstance().setUserName(session!.userName)

                // Log Answers Custom Event.
                Answers.logLogin(withMethod: "Twitter", success: true, customAttributes: ["User ID": session!.userID])
            } else {
                // Log Answers Custom Event.
                Answers.logLogin(withMethod: "Twitter", success: false, customAttributes: ["Error": error!.localizedDescription])
            }
        }
    }

    @IBAction func signInWithPhone(_ sender: UIButton) {
        // Create a Digits appearance with Cannonball colors.
        let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
        
        configuration?.appearance = DGTAppearance()
        configuration?.appearance.backgroundColor = UIColor.cannonballBeigeColor()
        configuration?.appearance.accentColor = UIColor.cannonballGreenColor()

        // Start the Digits authentication flow with the custom appearance.
        Digits.sharedInstance().authenticate(with: nil, configuration:configuration!) { (session, error) in
            if session != nil {
                // Navigate to the main app screen to select a theme.
                self.navigateToMainAppScreen()

                // Tie crashes to a Digits user ID in Crashlytics.
                Crashlytics.sharedInstance().setUserIdentifier(session?.userID)

                // Log Answers Custom Event.
                Answers.logLogin(withMethod: "Digits", success: true, customAttributes: ["User ID": session?.userID as Any])
            } else {
                // Log Answers Custom Event.
                Answers.logLogin(withMethod: "Digits", success: false, customAttributes: ["Error": error?.localizedDescription as Any])
            }
        }
    }

    @IBAction func skipSignIn(_ sender: AnyObject) {
        // Log Answers Custom Event.
        Answers.logCustomEvent(withName: "Skipped Sign In", customAttributes: nil)
    }

    // MARK: Utilities

    fileprivate func decorateButton(_ button: UIButton, color: UIColor) {
        // Draw the border around a button.
        button.layer.masksToBounds = false
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 6
    }

}

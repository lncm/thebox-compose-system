## How to contribute to this project

#### **Did you find a bug?**

* **Ensure the bug was not already reported** by searching on GitHub under [Issues](https://github.com/lncm/thebox-compose-system/issues).

* If you're unable to find an open issue addressing the problem, [open a new one](https://github.com/lncm/thebox-compose-system/issues/new). Be sure to include a **title and clear description**, as much relevant information as possible, and try to include a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

#### **Did you write a patch that fixes a bug?**

* Clone this repo

* Create a branch in your cloned repo either on the web or from CLI ```git checkout -b your_branch_name```

* Push the branch and then open a Pull request

* Ensure the PR description clearly describes the problem and solution. Include the relevant issue number if applicable.

* If you haven't done a test build yet, please mention this in the pull request. This will save a world of pain for future builds. There is no regression testing suite set up yet but this is something that we're looking into. Contributions are welcome.

##### GPG Signing

Please GPG sign all your commits and also consider gpg signing any text files.

A `.gitconfig` should look similar to this

```
[user]
        signingkey = YOURKEY
        name = YOURGITDISPLAYNAME
        email = YOUR@GIT.DISPLAY.EMAIL
[commit]
        gpgsign = true

```

###### Signing Text Files

```bash
# where FILENAME is the filename
gpg --armor --clearsign FILENAME
mv FILENAME.asc FILENAME

# To verify, simply to
gpg --verify FILENAME
```

#### **I'm not a developer, what can I do to help?**

We could definetely use some UX, QA or Build Systems support on this project. See getting in touch below or just [create an issue](https://github.com/lncm/thebox-compose-system/issues/new) and tag it with question.

Or send some donations via [**Lightning via tippin.me**](https://tippin.me/@lncnx)

#### **Getting in touch**

We accept contributions of all kinds, please contact us on [Twitter](https://twitter.com/lncnx) or contact one of us directly on Wire Messenger (userid: @corv , @nolim1t, or @meeDamian)

Main Repository Maintainer: [@nolim1t](https://github.com/nolim1t)


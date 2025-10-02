<!-- omit in toc -->
# Contributing to ActiveLRS

First off, thanks for taking the time to contribute! ❤️

All types of contributions are encouraged and valued. See the [Table of Contents](#table-of-contents) for different ways to help and details about how this project handles them. Please make sure to read the relevant section before making your contribution. It will make it a lot easier for us maintainers and smooth out the experience for all involved. The community looks forward to your contributions. 🎉

> And if you like the project, but just don't have time to contribute, that's fine. There are other easy ways to support the project and show your appreciation, which we would also be very happy about:
> - Star the project
> - Share the project on social media
> - Refer this project in your project's readme
> - Mention the project at local meetups and tell your friends/colleagues

<!-- omit in toc -->
## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [I Have a Question](#i-have-a-question)
- [I Want To Contribute](#i-want-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Documentation Issues / Improvement](#documentation-issues--improvement)
  - [Questions or Discussions](#questions-or-discussions)
  - [Pull Requests / Code Contributions](#pull-requests--code-contributions)
- [Styleguides](#styleguides)
  - [Commit Messages](#commit-messages)
- [Join The Project Team](#join-the-project-team)


## Code of Conduct

This project and everyone participating in it is governed by the
[ActiveLRS Code of Conduct](https://github.com/RaceRocks/activelrs/blob/main/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report unacceptable behavior
to admin@racerocks3d.com.


## I Have a Question

> If you want to ask a question, we assume that you have read the available [Documentation](https://rubydoc.info/github/RaceRocks/activelrs).

Before you ask a question, it is best to search for existing [Issues](https://github.com/RaceRocks/activelrs/issues) that might help you. In case you have found a suitable issue and still need clarification, you can write your question in this issue. It is also advisable to search the internet for answers first.

If you then still feel the need to ask a question and need clarification, we recommend the following:

- Open an [Issue](https://github.com/RaceRocks/activelrs/issues/new?template=question_discussion.md).
- Provide as much context as you can about what you're running into.
- Provide project and platform versions (nodejs, npm, etc), depending on what seems relevant.

We will then take care of the issue as soon as possible.


## I Want To Contribute

> ### Legal Notice <!-- omit in toc -->
> When contributing to this project, you must agree that you have authored 100% of the content, that you have the necessary rights to the content and that the content you contribute may be provided under the project licence.

### Reporting Bugs

<!-- omit in toc -->
#### Before Submitting a Bug Report

A good bug report shouldn't leave others needing to chase you up for more information. Therefore, we ask you to investigate carefully, collect information and describe the issue in detail in your report. Please complete the following steps in advance to help us fix any potential bug as fast as possible.

- Make sure that you are using the latest version.
- Determine if your bug is really a bug and not an error on your side e.g. using incompatible environment components/versions (Make sure that you have read the [documentation](https://rubydoc.info/github/RaceRocks/activelrs). If you are looking for support, you might want to check [this section](#i-have-a-question)).
- To see if other users have experienced (and potentially already solved) the same issue you are having, check if there is not already a bug report existing for your bug or error in the [bug tracker](https://github.com/RaceRocks/activelrs/issues?q=label%3Abug).
- Also make sure to search the internet (including Stack Overflow) to see if users outside of the GitHub community have discussed the issue.
- Collect information about the bug:
  - Stack trace (Traceback)
  - OS, Platform and Version (Windows, Linux, macOS, x86, ARM)
  - Version of the interpreter, compiler, SDK, runtime environment, package manager, depending on what seems relevant.
  - Possibly your input and the output
  - Can you reliably reproduce the issue? And can you also reproduce it with older versions?

<!-- omit in toc -->
#### How Do I Submit a Good Bug Report?

> You must never report security related issues, vulnerabilities or bugs including sensitive information to the issue tracker, or elsewhere in public. Instead sensitive bugs must be sent by email to admin@racerocks3d.com.
<!-- You may add a PGP key to allow the messages to be sent encrypted as well. -->

We use GitHub issues to track bugs and errors. If you run into an issue with the project:

- Open an [Bug Report Issue](https://github.com/RaceRocks/activelrs/issues/new?template=bug_report.md) using our **Bug Report template**. *(Since we can't be sure at this point whether it is a bug or not, please do **not** label the issue or claim it is a bug outside of this template.)*
- Explain the behavior you would expect and the actual behavior.
- Please provide as much context as possible and describe the *reproduction steps* that someone else can follow to recreate the issue on their own. This usually includes your code. For good bug reports you should isolate the problem and create a reduced test case.
- Provide the information you collected in the previous section.

Once it's filed:

- The project team will label the issue accordingly.
- A team member will try to reproduce the issue with your provided steps. If there are no reproduction steps or no obvious way to reproduce the issue, the team will ask you for those steps and mark the issue as `needs-repro`. Bugs with the `needs-repro` tag will not be addressed until they are reproduced.
- If the team is able to reproduce the issue, it will be marked `needs-fix`, as well as possibly other tags (such as `critical`), and the issue will be left to be [implemented by someone](#pull-requests--code-contributions).

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for ActiveLRS, **including completely new features and minor improvements to existing functionality**. Following these guidelines will help maintainers and the community to understand your suggestion and find related suggestions.

<!-- omit in toc -->
#### Before Submitting an Enhancement

- Make sure that you are using the latest version.
- Read the [documentation](https://rubydoc.info/github/RaceRocks/activelrs) carefully and find out if the functionality is already covered, maybe by an individual configuration.
- Perform a [search](https://github.com/RaceRocks/activelrs/issues) to see if the enhancement has already been suggested. If it has, add a comment to the existing issue instead of opening a new one.
- Find out whether your idea fits with the scope and aims of the project. It's up to you to make a strong case to convince the project's developers of the merits of this feature. Keep in mind that we want features that will be useful to the majority of our users and not just a small subset. If you're just targeting a minority of users, consider writing an add-on/plugin library.

<!-- omit in toc -->
#### How Do I Submit a Good Enhancement Suggestion?

Enhancement suggestions are tracked as [GitHub issues](https://github.com/RaceRocks/activelrs/issues).

- Open a new [Feature Request issue](https://github.com/RaceRocks/activelrs/issues/new?template=feature_request.md) using our **Feature Request template**.
- Use a **clear and descriptive title** for the issue to identify the suggestion.
- Provide a **step-by-step description of the suggested enhancement** in as many details as possible.
- **Describe the current behavior** and **explain which behavior you expected to see instead** and why. At this point you can also tell which alternatives do not work for you.
- You may want to **include screenshots or screen recordings** which help you demonstrate the steps or point out the part which the suggestion is related to. You can use [LICEcap](https://www.cockos.com/licecap/) to record GIFs on macOS and Windows, and the built-in [screen recorder in GNOME](https://help.gnome.org/users/gnome-help/stable/screen-shot-record.html.en) or [SimpleScreenRecorder](https://github.com/MaartenBaert/ssr) on Linux.
- **Explain why this enhancement would be useful** to most ActiveLRS users. You may also want to point out the other projects that solved it better and which could serve as inspiration.


### Documentation Issues / Improvement

For missing, incorrect, or unclear documentation:

- Open a new [Documentation Issue](https://github.com/RaceRocks/activelrs/issues/new?template=documentation_issue.md) using the **Documentation Issue template**.
- Provide links to the affected docs and suggested corrections.


### Questions or Discussions

For questions, clarifications, or discussions that are not bugs or feature requests:

- Open a new [Question / Discussion issue](https://github.com/RaceRocks/activelrs/issues/new?template=question_discussion.md) using the **Question / Discussion template**.
- Provide context, examples, and any steps you’ve already tried.


### Pull Requests / Code Contributions

- When submitting code changes, always use the [Pull Request template](https://github.com/RaceRocks/activelrs/pull/new/main) to guide your PR description.
- Include:
  - What changes you made and why
  - Related issue(s)
  - Updates to tests or documentation if applicable
- Ensure your code passes linting, tests, and CI checks.
- Check that your changes align with the project documentation.


## Styleguides
### Commit Messages

To keep history readable and consistent, please follow these guidelines for commit messages:

- Use the **imperative mood** (e.g., `Add`, `Fix`, `Update`)  
  - ✅ Correct: `Add new XAPI statement validation`  
  - ❌ Incorrect: `Added new XAPI statement validation`
- Keep the **subject line ≤ 50 characters**, followed by a blank line, then a more detailed body if needed.  
- Capitalize the first letter of the subject line.  
- Reference related issues when applicable: `Fixes #42`
- For larger changes, include a summary of **what** and **why** in the body.  
- Avoid unnecessary punctuation (no trailing periods in the subject line). 

**Example:**
```text
Fixes #42 - Refactor Agent class to simplify object_type handling

- Move object_type attribute to parent class
- Update documentation for clarity
- Add unit tests for new behavior
```

## Join The Project Team

We welcome contributors of all experience levels. Here’s how to get involved:

1. **Start by contributing issues or documentation improvements**.  
   Use the templates to submit bug reports, feature requests, or documentation updates.

2. **Submit code contributions** via pull requests using the PR template.

3. **Engage with the community**:
   - Participate in discussions on issues and PRs.
   - Provide feedback or help review contributions when possible.

> By joining the project team, you agree to uphold the project's code of conduct and contribute constructively.


<!-- omit in toc -->
## Attribution
This guide is based on the [contributing.md](https://contributing.md/generator)!
# HotCI Usage example

Usage example for [HotCI](https://github.com/Ahzed11/HotCI).

## TLDR

See: [Conclusion](https://github.com/Ahzed11/HotCI-usage-example?tab=readme-ov-file#conclusion).

## Introduction

This README introduces the usage of the HotCI template with a new
project by providing a practical example. The result of this example is this repository.

This example features a subset versions 0.2.0 and 0.3.0 of [Pixelwar](https://github.com/Ahzed11/pixelwar).

## Creating a new project

To begin, initiate a new Github repository using the ["Use this template" button](https://github.com/new?template_name=HotCI&template_owner=Ahzed11) from the top right of the HotCI repository. This action sets up a fresh repository based on the HotCI template.

Next, clone the newly created repository into a folder named
`pixelwar`:

``` sh
git clone git@github.com:Username/repository.git pixelwar
```

Note that instead of pixelwar, any name can be chosen. In this case, a name was given to make sure that the reader and these instructions use the same directory name.

With that done, generate a release template using Rebar3:

``` sh
rebar3 new release pixelwar
```

This step simulates the creation of a new release project with Rebar3. Note that Rebar3 will not overwrite the existing files with the generated ones.

Navigate to the pixelwar directory and replace all occurences of the word `release_name` that are present in `rebar.config` with
`pixelwar`:

``` sh
cd pixelwar && sed -i -e 's/release_name/pixelwar/g' rebar.config
```

This step is required because the template does not know what the name of the new release is and the atom `release_name` acts as a
placeholder.

Finally, add all files to Git, commit the changes and push them to the repository.

``` sh
git add --all &&
git commit -m "release template generated with rebar3" &&
git push
```

## Creating a first version of the release

Let us now simulate the creation of the first release version by introducing Pixelwar version 0.2.0 into its apps.

Start by creating a new branch. It can have any name, however, for this example, the name `first-version` will be used:

``` sh
git checkout -b first-version
```

Next, remove all files located under `apps/pixelwar/src` and replace them with the files present in the `first-version` branch of this repository to mimic updates to the `pixelwar` application.

Do the same for the `apps/pixelwar/test` folder.

Once done, stage the changes, commit them, and push to the repository:

``` sh
git add apps/pixelwar/ &&
git commit -m "add pixelwar 0.2.0" &&
git push --set-upstream origin first-version
```

Open a pull request for this branch through the GitHub user interface.

It is worth noting that creating a pull request is not strictly required in this case, because no hot code upgrade can be tested due to the absence of a previous version.

However creating a pull request is required for later versions because the template assumes, to perform hot code upgrade testing, that each version is developed in a different pull request.

After opening the pull request, GitHub will trigger the `erlang-ci`
and `relup-ci` workflows. Since there is no previous version from
which to perform a hot code upgrade, the `relup-ci` workflow will halt early without producing any errors.

Upon workflows's completion, GitHub should indicate that all test cases pass. Moreover, a summary of the `erlang-ci` workflow's results should be displayed in the pull request feed.

## Releasing the first version

Now that the first version is ready, a Github release can be created thanks to the `publish-tarball` Github workflow.

Begin by navigating to the pull request page for the `first-version` branch on Github. Click on `Merge pull request` and then `Confirm merge`. After merging, checkout to the `main` branch and pull the changes:

``` sh
git checkout main &&
git pull
```

Once on the `main` branch, create a new git tag for version 0.0.1 and push it to the origin:

``` sh
git tag -a v0.0.1 -m "First version" &&
git push origin v0.0.1
```

Pushing a tag with the `v[0-9]+.[0-9]+.[0-9]` regex format triggers the publish-tarball workflow, which builds and publishes the release under a GitHub release named v0.0.1.

In line with the [Smoothver](https://github.com/Ahzed11/HotCI?tab=readme-ov-file#versioning) versioning scheme, by default, the `0.0.1` version number is defined in HotCI's rebar.config because the first version does not require a full system restart or a state migration.

## Creating a second version of the release

Let's now simulate the modification and update to the first release by incorporating Pixelwar version 0.3.0.

Start, by creating a new branch named `second-version`:

``` sh
git checkout -b second-version
```

Next, remove all files located under `apps/pixelwar/src` and replace them with the files present in the `second-version` branch of this repository to mimic updates to the `pixelwar` application.

Do the same for the `apps/pixelwar/test` folder.

Update the `rebar.config` file, located at the project root, by
changing the release version from `0.0.1` to `0.1.0` to bump the
release version.

This is in line with Semver. The second version number, representing the RELUP version number, is incremented because a state migration is required between the first and the second version.

Once done, stage the changes, commit them, and push to the repository:

``` sh
git add apps/pixelwar/ &&
git add rebar.config &&
git commit -m "add pixelwar 0.3.0" &&
git push --set-upstream origin second-version
```

Then, open a pull request for this branch through the GitHub user interface.

After the pull request, GitHub will trigger the `erlang-ci` and `relup-ci` workflows. This time, as a previous version exists, `relup-ci` will not halt early and will run the `upgrade_downgrade_SUITE.erl` CT test suite.

Upon completion, Github should indicate that all the cases pass and a summary of the erlang-ci workflow's results should be displayed in the pull request's feed.

## Modifying the upgrade_downgrade_SUITE

It is time to focus on testing the upgrade and downgrade of the application. The previous run of the `relup-ci` workflow passed because the `upgrade_downgrade_SUITE` provided with HotCI only verifies if the system was able to upgrade and downgrade successfully.

However, this success is not sufficient to assert that the transition function applied from one version to the other is correct. For instance, the upgrade could lead to the new version running successfully but with an invalid state.

Testing the state of the release requires some modifications to the upgrade_downgrade_SUITE located under the test folder.

First, to modify the state of the release before the upgrade, let us replace the before_upgrade_case function and its body with the following code:

```erlang
before_upgrade_case(Config) ->
    Peer = ?config(peer, Config),

    peer:call(Peer, pixelwar_matrix_serv, set_element, [matrix, {12, 12, 12}]),
    peer:call(Peer, pixelwar_matrix_serv, set_element, [matrix, {112, 112, 112}]),
    
    MatrixAsBin = peer:call(Peer, pixelwar_matrix_serv, get_state, [matrix]),
    ?assertEqual(
        MatrixAsBin,
        <<12:16/little, 12:16/little, 12:16/little, 112:16/little, 112:16/little, 112:16/little>>
    ).
```

This code modifies the pixelwar matrix server by inserting two pixels.
It also asserts that they have been correctly inserted into the matrix.

Then, to verify the state of the release after the upgrade, let us
replace the after_upgrade_case function and its body with the following
code:

``` erlang
after_upgrade_case(Config) ->
    Peer = ?config(peer, Config),

    MatrixAsBin = peer:call(Peer, pixelwar_matrix_serv, get_state, [matrix]),
    ?assertEqual(
        MatrixAsBin,
        <<12:16/little, 12:16/little, 12:16/little, 112:16/little, 112:16/little, 112:16/little>>
    ).
```

This code asserts that the two pixels that have been inserted earlier
are still present and in the expected format. This test is done because
the representation of the matrix server's state is modified between the
version 0.2.0 and 0.3.0 of the pixelwar application.

Finally, similar modifications are done to the before_downgrade_case and
the after_downgrade_case functions to verify that a rollback to the
older version also works.

```erlang
before_downgrade_case(Config) ->
    Peer = ?config(peer, Config),

    peer:call(Peer, pixelwar_matrix_serv, set_element, [matrix, {13, 13, 13}]),
    
    MatrixAsBin = peer:call(Peer, pixelwar_matrix_serv, get_state, [matrix]),
    ?assertEqual(
        MatrixAsBin,
        <<12:16/little, 12:16/little, 12:16/little, 13:16/little, 13:16/little, 13:16/little, 112:16/little, 112:16/little, 112:16/little>>
    ).
```

```erlang
after_downgrade_case(Config) ->
    Peer = ?config(peer, Config),

    MatrixAsBin = peer:call(Peer, pixelwar_matrix_serv, get_state, [matrix]),
    ?assertEqual(
        MatrixAsBin,
        <<12:16/little, 12:16/little, 12:16/little, 13:16/little, 13:16/little, 13:16/little, 112:16/little, 112:16/little, 112:16/little>>
    ).
```

For demonstration purpose, the preceding tests are kept simple. However, they can be arbitrarily complex. As the test suite is a CT test suite, more cases can be added, and any Erlang module can be used.

Now that the `upgrade_downgrade_SUITE` has been modified, stage the changes, commit them, and push to the repository:

``` sh
git add test &&
git commit -m "implement cases in the upgrade_downgrade_SUITE" &&
git push
```

## Releasing the second version

With everything set, a new Github release can be created.

Begin by navigating to the pull request page for the `second-version` branch on Github. Click on `Merge pull request` and then `Confirm merge`. After merging, switch to the `main` branch and pull the changes:

``` sh
git checkout main &&
git pull
```

Once on the `main` branch, create a new git tag for version 0.1.0 and push it to the origin:

``` sh
git tag -a v0.1.0 -m "Second version" &&
git push origin v0.1.0
```

## Conclusion

To wrap up, this example demonstrates HotCI's Git-integrated ceremony, summarized as follows:

1. Create a new branch and pull request for the new version

2. Apply modifications to the code

3. Select a version number following [Smoothver](https://github.com/Ahzed11/HotCI?tab=readme-ov-file#versioning)

4. Bump the application and release version

5. If the version does not require a restart, update the\
    upgrade_downgrade_SUITE

6. Merge the pull request

7. Add a version tag to create a Github Release

This rather simple ceremony ensures the unit testing of the module, the testing of the hot code upgrades and downgrades and the publication of releases.

/**
 * Created by Henry Huang on 10/14/17.
 */
const gh = require('ghreleases');

const auth = {
  token: process.env.GitHubToken,
  user: 'henryhuang'
};

const org = 'teambebop6';
const repo = 'anktours';

gh.getLatest(auth, org, repo, function (err, release) {
    if (release && release.assets) {
      console.log(release)
    } else {
      console.log('There are not any releases!');
    }
  }
);
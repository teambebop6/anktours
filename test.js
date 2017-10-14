/**
 * Created by Henry Huang on 10/14/17.
 */
const gh = require('ghreleases');

auth = {
  token: process.env.GitHubToken,
  user: 'henryhuang'
};

org = 'teambebop6'
repo = 'anktours'

gh.getLatest(auth, org, repo, function (err, release) {
    if (release && release.assets) {
      console.log(release.assets[0].browser_download_url)
    } else {
      console.log('There are not any releases!');
    }
  }
)
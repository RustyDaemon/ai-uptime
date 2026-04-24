import 'models/service.dart';

const appTitle = 'AI Uptime';
const popoverChannelName = 'ai_uptime/popover';

const defaultPollIntervalSeconds = 60;
const pollIntervalChoices = <int>[60, 300, 600, 1500];

const httpTimeout = Duration(seconds: 15);

enum GitHubRegion {
  us('us', 'US', 'https://www.githubstatus.com'),
  eu('eu', 'EU', 'https://eu.githubstatus.com'),
  au('au', 'Australia', 'https://au.githubstatus.com'),
  jp('jp', 'Japan', 'https://jp.githubstatus.com');

  final String id;
  final String label;
  final String baseUrl;
  const GitHubRegion(this.id, this.label, this.baseUrl);

  static GitHubRegion fromId(String? id) =>
      values.firstWhere((r) => r.id == id, orElse: () => GitHubRegion.eu);
}

const defaultGitHubRegion = GitHubRegion.eu;

const kServiceClaude = MonitoredService(
  id: 'claude',
  name: 'Claude',
  baseUrl: 'https://status.claude.com',
  componentFilter: null,
);

MonitoredService gitHubService(GitHubRegion region) => MonitoredService(
  id: 'github',
  name: 'GitHub',
  baseUrl: region.baseUrl,
  componentFilter: null,
);

const kServiceOpenAI = MonitoredService(
  id: 'openai',
  name: 'OpenAI',
  baseUrl: 'https://status.openai.com',
  componentFilter: null,
);

const kServiceCursor = MonitoredService(
  id: 'cursor',
  name: 'Cursor',
  baseUrl: 'https://status.cursor.com',
  componentFilter: null,
);

List<MonitoredService> monitoredServices(GitHubRegion region) => [
  kServiceClaude,
  gitHubService(region),
  kServiceOpenAI,
  kServiceCursor,
];

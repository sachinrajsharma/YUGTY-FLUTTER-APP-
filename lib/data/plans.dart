/// Seeker packages. Source: "Seeker Packages.pdf" (YUGTY Campus folder).
/// An empty string means the feature is not included in that package.
class Plan {
  final String name;
  final String price; // display price, '' for free
  final String tagline;
  final String validity;
  final bool popular;
  const Plan(this.name, this.price, this.tagline, this.validity, {this.popular = false});
  bool get isFree => price.isEmpty;
}

class Feature {
  final String key;
  final String label;
  final String hint;
  final List<String> values; // one per plan, in [plans] order
  const Feature(this.key, this.label, this.hint, this.values);
}

const plans = <Plan>[
  Plan('Explorer', '', 'Try the essentials, no card needed.', 'Lifetime'),
  Plan('Starter', '₹299.00', 'Build your first job-ready profile.', '30 days'),
  Plan('Pro', '₹499.00', 'Stand out with verified, shareable proof.', '60 days', popular: true),
  Plan('Elite', '₹999.00', 'The complete career toolkit with expert help.', '90 days'),
];

const features = <Feature>[
  Feature('passport', 'Career Passport', '', [
    'Basic',
    'Verified Passport',
    'Verified + Shareable Link',
    'Verified + Featured Profile'
  ]),
  Feature('resume', 'Resume Studio', 'Templates', [
    '3',
    '10',
    '30',
    'All Templates (50+) incl. Premium'
  ]),
  Feature('ats', 'ATS Friendly Resumes', '', [
    '',
    'ATS Format',
    'ATS Score + Optimization',
    'ATS Score + Optimization + Expert Review'
  ]),
  Feature('cover', 'Cover Letter', '', ['3', '10', '30', '50+']),
  Feature('interview', 'Interview Practice', 'Audio & Video', [
    '01 Each',
    '05 Each + AI Feedback',
    '10 Each + Detailed AI Report',
    '20 Each + Detailed AI Report'
  ]),
  Feature('courses', 'Courses', '', [
    'Browse Full Catalogue',
    'Pick any 2',
    'Pick any 3 + Certificates',
    'Pick any 5 + Certificates'
  ]),
  Feature('video', 'Video Resume', '', [
    'Knowledge about Video Resume',
    '01 Guided Video Resume',
    '02 Video Resumes + AI Review',
    '05 Video Resumes + 1 Expert Feedback on the Primary Resume'
  ]),
  Feature('social', 'Social Branding (PR)',
      'LinkedIn / Instagram / YouTube / X / Facebook', [
    '01 Post (one platform) (Monthly)',
    '04 Posts (Platform of your choice) Monthly',
    '05 Posts (Platform of your choice) + Profile Headline & Bio of any one platform',
    '10 Posts (Platform of your choice) + Full Profile Makeover of any one platform'
  ]),
  Feature('jobs', 'Job Finder & Matching', '', [
    '',
    '02 Matched Jobs/Internships per month*',
    '05 Matched Jobs/Internships per month + Match Score*',
    '10 Matched Jobs/Internships + Application Tracker + Job Alerts*'
  ]),
  Feature('guidance', 'Expert Guidance', '', [
    '',
    '',
    '01 Group Session (Career Clarity) 30 mins',
    '02 Group Sessions (30 mins each) + Career Roadmap'
  ]),
  Feature('mentor', 'Mentor Session (1:1)', '', [
    '',
    '',
    '',
    '02 Sessions (30 min each)'
  ]),
  Feature('support', 'Support', '', [
    'Community / FAQ',
    'Email Support',
    'Priority Email & Chat',
    'Priority WhatsApp Support (24 hr response)'
  ]),
];

const conditionsNote =
    '*Conditions apply. Job matching is valid for working professionals. In the case of students '
    '(final year, final semester), internship matching is for final year students only.';

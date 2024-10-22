# pulumi-vercel-multi-domain-demo

## Set up pulumi

You'll want to [sign up](https://app.pulumi.com/signup) for a Pulumi account.

### Installation

You can go straight to [downloads](https://www.pulumi.com/docs/iac/download-install/) or use one of the methods, below.

**OSX**

```
brew install pulumi/tap/pulumi
```

**Windows**

```
choco install pulumi
```

**Linux**
Your own package manager, or:

```
curl -fsSL https://get.pulumi.com | sh
```

### Login

```
pulumi login
```

## Set up your environments

The [getting started guide](https://www.pulumi.com/docs/esc/get-started/begin/) is helpful, but you do **not** need to install the ESC CLI - the Pulumi CLI is a superset of that functionality (accessible by running `pulumi env`).

This demo uses 4 environment types overall.

**Base environment** - 1 globally

This should contain the variables that are required by all (or most) of your environments.

This demo requires only the vercel team ID and API token:

```
values:
  vercel:
    team_id: your-team-id
    api_token:
      fn::secret:
        some-secret-value-that-pulumi-will-encrypt-when-you-save-it
```

**Org environment** - 1 per org

This should contain all the variables that are specific to the organization.

This demo requires only the org name and its URL slug:

```
imports:
  - your-esc-project-name/your-base-environment-name
values:
  org:
    name: Your Human-Readable Org Name
    slug: your-org-slug
```

**IAC environment** - 1 per org

This contains no new configuration, simply cherry-picking the environment variables necessary for the deployment.

This demo expect this environment to be named: "{org-slug}-iac"

This demo requires 3 environment variables to deploy via IAC:

```
imports:
  - your-esc-project-name/your-org-environment-name
values:
  environmentVariables:
    ORG_SLUG: ${org.slug}
    VERCEL_TEAM_ID: ${vercel.team_id}
    VERCEL_API_TOKEN: ${vercel.api_token}
```

**Vite environment** - 1 per org

This contains no new configuration, simply cherry-picking the environment variables necessary for the deployment.

This demo expect this environment to be named: "{org-slug}-vite"

This demo requires 2 environment variables to build the vite app:

```
imports:
  - your-esc-project-name/your-org-environment-name
values:
  environmentVariables:
    PUBLIC_ORG_NAME: ${org.name}
    PUBLIC_ORG_SLUG: ${org.slug}
```

## The scripts

You need to set the PULUMI_ORG, PULUMI_IAC_PROJECT, and PULUMI_ESC_PROJECT environment variables to your own values.

Here are my values, for example. Note that even though the IAC and ESC project are the same, here, they can be different - I just named them the same thing.

```
export PULUMI_ORG=codefold
export PULUMI_IAC_PROJECT=vercel-multi-domain
export PULUMI_ESC_PROJECT=vercel-multi-domain
```

Any org slugs used here are assumed to have preexisting IAC and Vite configurations.

**Deploy one organization:**

```
./scripts/deploy.sh your-org-slug
```

**Deploy multiple organization**

```
./scripts/deploy-many.sh org-slug-1 org-slug-2 org-slug-3
```

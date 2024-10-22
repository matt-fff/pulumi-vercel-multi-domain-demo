import pulumi
import pulumiverse_vercel as vercel
import os

org_slug = os.environ["ORG_SLUG"]
team_id = os.environ["VERCEL_TEAM_ID"]

# Define Vercel project
vercel_project = vercel.Project(f"{org_slug}-vercel-project",
    name=org_slug,
    team_id=team_id,
    framework='sveltekit-1',
)

site_path = "../demo-site/"
project_files = vercel.get_project_directory(site_path)

# Add a Vercel deployment
vercel_deployment = vercel.Deployment(f"{org_slug}-vercel-deployment",
    team_id=team_id,
    project_id=vercel_project.id,
    files=project_files.files,
    path_prefix=site_path,
    production=True
)

pulumi.export("vercel_deployment_url", vercel_deployment.url)

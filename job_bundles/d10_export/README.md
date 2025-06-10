# Deadline 10 Export Job

## Background

Deadline 10 is the predecessor to Deadline Cloud. It had a different Job structure than Deadline Cloud, and required the use of application-specific render plugins that were responsible for wrapping various content creation applications in a common interface.

## Job Summary

This job bundle takes a Deadline 10 plugin directory and Job definition as input, and renders the job using its associated plugin.

Any files referenced by the Deadline 10 job (either in the Job/Plugin Info files, or the scene itself) should be specified as inputs in the Job Attachments tab. Similarly, the output folder should be specified as an output in the Job Attachment tab.

A copy of the Blender plugin, and sample Blender Job/Plugin info files have been provided for reference, but this bundle should work by specifying your own sourced from a local Deadline 10 deployment.

## Requirements

This job bundle relies on the `deadline-10-runtime` conda package, which can be built from the sample conda recipe included in this repository's `conda_recipes` folder.

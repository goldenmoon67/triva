#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
target = project.targets.find { |t| t.name == 'Runner' }

# Find and remove the Crashlytics build phase
crashlytics_phase = target.build_phases.find { |phase| phase.display_name.include?('FlutterFire: "flutterfire upload-crashlytics-symbols"') }
target.build_phases.delete(crashlytics_phase) if crashlytics_phase

# Save the project
project.save

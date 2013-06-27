
(load-this-project
 `( (:ruby-executable ,*ruby-1.9-executable*)
    (:run-project-command (ruby-run-file ,(concat (project-base-directory) "correspondence-ml.rb")))
    (:build-function project-compile-with-command)
    (:compile-command "rake")
    (:run-project-command (rspec-file ,(concat (project-base-directory) "spec/parser_spec.rb")))
    (:ruby-args (,(concat "-I" (project-base-directory) "lib")))
    ) )

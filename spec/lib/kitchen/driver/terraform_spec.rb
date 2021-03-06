# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "json"
require "kitchen/driver/terraform"
require "support/dry/monads/either_matchers"
require "support/kitchen/driver/terraform/config_attribute_cli_examples"
require "support/kitchen/driver/terraform/config_attribute_color_examples"
require "support/kitchen/driver/terraform/config_attribute_command_timeout_examples"
require "support/kitchen/driver/terraform/config_attribute_directory_examples"
require "support/kitchen/driver/terraform/config_attribute_parallelism_examples"
require "support/kitchen/driver/terraform/config_attribute_plan_examples"
require "support/kitchen/driver/terraform/config_attribute_state_examples"
require "support/kitchen/driver/terraform/config_attribute_variable_files_examples"
require "support/kitchen/driver/terraform/config_attribute_variables_examples"
require "support/kitchen/driver/terraform/workflow_context"
require "support/kitchen/driver/terraform_context"
require "support/kitchen/terraform/client/execute_command_context"
require "support/kitchen/terraform/client/version_context"
require "support/terraform/configurable_context"
require "support/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Driver::Terraform do
  include_context "instance"

  let :described_instance do
    driver
  end

  shared_examples "a workflow action" do
    context "when the workflow function results in failure" do
      include_context "Kitchen::Driver::Terraform"

      it "raises an action failed error" do
        is_expected.to raise_error ::Kitchen::ActionFailed, /driver workflow/
      end
    end

    context "when the workflow function results in success" do
      include_context "Kitchen::Driver::Terraform", failure: false

      it "does not raise an error" do
        is_expected.to_not raise_error
      end
    end
  end

  it_behaves_like ::Terraform::Configurable

  it_behaves_like "config attribute :cli"

  it_behaves_like "config attribute :command_timeout"

  it_behaves_like "config attribute :color"

  it_behaves_like "config attribute :directory"

  it_behaves_like "config attribute :parallelism"

  it_behaves_like "config attribute :plan"

  it_behaves_like "config attribute :state"

  it_behaves_like "config attribute :variable_files"

  it_behaves_like "config attribute :variables"

  describe ".serial_actions" do
    subject do
      described_class.serial_actions
    end

    it "is empty" do
      is_expected.to be_empty
    end
  end

  describe "#create" do
    subject do
      lambda do
        described_instance.create instance_double ::Object
      end
    end

    it_behaves_like "a workflow action"
  end

  describe "#destroy" do
    subject do
      lambda do
        described_instance.destroy instance_double ::Object
      end
    end

    it_behaves_like "a workflow action"
  end

  describe "#output" do
    subject do
      described_instance.output
    end

    context "when the output function results in failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "output"

      it do
        is_expected.to result_in_failure.with_the_value /terraform output/
      end
    end

    context "when the output function results in success" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "output",
                                                                    exit_code: 0,
                                                                    output: ::JSON.generate("key" => "value")

      it do
        is_expected.to result_in_success.with_the_value "key" => "value"
      end
    end
  end

  describe "#verify_dependencies" do
    subject do
      lambda do
        described_instance.verify_dependencies
      end
    end

    shared_examples "the verification of dependencies is a failure" do
      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError
      end
    end

    context "when the result of the version function is a failure" do
      include_context "Kitchen::Terraform::Client::Version"

      it_behaves_like "the verification of dependencies is a failure"
    end

    context "when the result of the version verification function is a failure" do
      include_context "Kitchen::Terraform::Client::Version", failure: false, version: 0.1

      it_behaves_like "the verification of dependencies is a failure"
    end

    context "when the result of the version verification function is a success" do
      include_context "Kitchen::Terraform::Client::Version", failure: false, version: 0.9

      it "does not raise an error" do
        is_expected.to_not raise_error
      end
    end
  end
end

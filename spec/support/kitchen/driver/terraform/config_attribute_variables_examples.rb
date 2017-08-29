# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "support/kitchen/terraform/define_config_attribute_context"

::RSpec.shared_examples "config attribute :variables" do
  include_context(
    "Kitchen::Terraform::DefineConfigAttribute",
    attribute: :variables
  ) do
    context "when the config omits :variables" do
      it_behaves_like(
        "a default value is used",
        default_value: {}
      )
    end

    context "when the config associates :variables with a nonhash" do
      it_behaves_like(
        "the value is invalid",
        error_message: /variables.*must be a hash/,
        value: []
      )
    end

    context "when the config associates :variables with a an empty hash" do
      it_behaves_like(
        "the value is valid",
        value: {}
      )
    end

    context "when the config associates :variables with a hash which has nonsymbol keys" do
      it_behaves_like(
        "the value is invalid",
        error_message: /variables.*keys must be symbols/,
        value: {"key" => "value"}
      )
    end

    context "when the config associates :variables with a hash which has nonstring values" do
      it_behaves_like(
        "the value is invalid",
        error_message: /variables.*values must be strings/,
        value: {key: :value}
      )
    end

    context "when the config associates :variables with a hash which has symobl keys and string values" do
      it_behaves_like(
        "the value is valid",
        value: {key: "value"}
      )
    end
  end
end

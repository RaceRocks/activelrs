require "time"

module ActiveLrs
  # Namespace for xAPI-related models and classes.
  #
  # This module contains all the core classes for representing xAPI statements,
  # actors, activities, results, context, and related components.
  #
  # All classes are autoloaded to reduce memory usage and improve load time.
  #
  # @!macro [new] xapi_classes
  #   @!attribute [r] Activity
  #     @return [Class] xAPI Activity object
  #   @!attribute [r] ActivityDefinition
  #     @return [Class] xAPI ActivityDefinition object
  #   @!attribute [r] Agent
  #     @return [Class] xAPI Agent object
  #   @!attribute [r] AgentAccount
  #     @return [Class] xAPI AgentAccount object
  #   @!attribute [r] Attachment
  #     @return [Class] xAPI Attachment object
  #   @!attribute [r] Context
  #     @return [Class] xAPI Context object
  #   @!attribute [r] ContextActivities
  #     @return [Class] xAPI ContextActivities object
  #   @!attribute [r] Group
  #     @return [Class] xAPI Group object
  #   @!attribute [r] InteractionComponent
  #     @return [Class] xAPI InteractionComponent object
  #   @!attribute [r] Result
  #     @return [Class] xAPI Result object
  #   @!attribute [r] Score
  #     @return [Class] xAPI Score object
  #   @!attribute [r] StatementBase
  #     @return [Class] Base class for xAPI statements
  #   @!attribute [r] StatementRef
  #     @return [Class] xAPI StatementRef object
  #   @!attribute [r] Statement
  #     @return [Class] xAPI Statement object
  #   @!attribute [r] SubStatement
  #     @return [Class] xAPI SubStatement object
  #   @!attribute [r] Verb
  #     @return [Class] xAPI Verb object
  module Xapi
    autoload :Activity, "active_lrs/xapi/activity"
    autoload :ActivityDefinition, "active_lrs/xapi/activity_definition"
    autoload :Agent, "active_lrs/xapi/agent"
    autoload :AgentAccount, "active_lrs/xapi/agent_account"
    autoload :Attachment, "active_lrs/xapi/attachment"
    autoload :Context, "active_lrs/xapi/context"
    autoload :ContextActivities, "active_lrs/xapi/context_activities"
    autoload :Group, "active_lrs/xapi/group"
    autoload :InteractionComponent, "active_lrs/xapi/interaction_component"
    autoload :Result, "active_lrs/xapi/result"
    autoload :Score, "active_lrs/xapi/score"
    autoload :StatementBase, "active_lrs/xapi/statement_base"
    autoload :StatementRef, "active_lrs/xapi/statement_ref"
    autoload :Statement, "active_lrs/xapi/statement"
    autoload :SubStatement, "active_lrs/xapi/sub_statement"
    autoload :Verb, "active_lrs/xapi/verb"

    autoload :LocalizationHelper, "active_lrs/xapi/localization_helper"
  end
end

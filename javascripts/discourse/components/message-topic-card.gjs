import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ParticipantGroups from "discourse/components/topic-list/participant-groups";
import TopicExcerpt from "discourse/components/topic-list/topic-excerpt";
import TopicLink from "discourse/components/topic-list/topic-link";
import TopicStatus from "discourse/components/topic-status";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import DiscourseURL from "discourse/lib/url";
import { eq } from "discourse/truth-helpers";

export default class MessageTopicCard extends Component {
  @service currentUser;

  get filteredParticipants() {
    const topic = this.args.topic;
    const currentUsername = this.currentUser?.username;
    const featuredUsers = topic.featuredUsers || [];

    return featuredUsers.filter(poster => {
      const username = poster.user?.username || poster.username;
      return username !== currentUsername;
    });
  }

  get featuredUser() {
    const filteredUsers = this.filteredParticipants;
    if (filteredUsers.length > 0) {
      return filteredUsers[0].user || filteredUsers[0];
    }

    const topic = this.args.topic;
    const featuredUsers = topic.featuredUsers || [];
    const firstUser = featuredUsers[0];
    return (firstUser?.user || firstUser) || topic.creator;
  }

  @action
  handleCardClick(event) {
    if (wantsNewWindow(event)) {
      return true;
    }

    const target = event.target;
    const isInteractive = target.closest(
      'a, button, [role="button"], .topic-status'
    );

    if (!isInteractive) {
      event.preventDefault();
      DiscourseURL.routeTo(this.args.topic.lastUnreadUrl || this.args.topic.url);
    }
  }

  <template>
    <article class="message-topic-card">
      <a
        href={{@topic.lastUnreadUrl}}
        class="message-topic-card__link"
        {{on "click" this.handleCardClick}}
        {{on "auxclick" this.handleCardClick}}
      >
        <div class="message-topic-card__header">
          <h3 class="message-topic-card__title">
            <TopicStatus @topic={{@topic}} @context="topic-list" />
            <TopicLink @topic={{@topic}} class="title raw-link" />
            {{#if @topic.featured_link}}
              &nbsp;<a href={{@topic.featured_link}} class="topic-featured-link" target="_blank" rel="noopener noreferrer">{{@topic.featured_link}}</a>
            {{/if}}
          </h3>
          {{#if @topic.unseen}}
            <span class="topic-post-badges">
              &nbsp;<a href={{@topic.lastUnreadUrl}} title="new topic" class="badge badge-notification new-topic"> </a>
            </span>
          {{else if @topic.unread_posts}}
            <span class="topic-post-badges">
              &nbsp;<a href={{@topic.lastUnreadUrl}} class="badge badge-notification unread-posts" title="{{@topic.unread_posts}} unread posts">{{@topic.unread_posts}}</a>
            </span>
          {{/if}}
        </div>

        {{#if this.featuredUser}}
          <div class="message-topic-card__participant">
            {{#each this.filteredParticipants as |poster|}}
              {{avatar poster avatarTemplatePath="user.avatar_template" usernamePath="user.username" namePath="user.name" imageSize="small"}}
            {{/each}}
            <UserLink @user={{this.featuredUser}} class="message-topic-card__username">
              {{this.featuredUser.username}}
            </UserLink>
            <span class="message-topic-card__separator">•</span>
            <span class="message-topic-card__activity">
              {{formatDate @topic.bumpedAt leaveAgo="true" format="tiny"}}
            </span>
          </div>
        {{/if}}

        {{#if @topic.participant_groups}}
          <ParticipantGroups @topic={{@topic}} />
        {{/if}}

        {{#if @topic.hasExcerpt}}
          <div class="message-topic-card__excerpt">
            <TopicExcerpt @topic={{@topic}} />
          </div>
        {{/if}}

        {{#if @topic.replyCount}}
          <div class="message-topic-card__meta">
            <span class="message-topic-card__replies">
              {{@topic.replyCount}}
              {{#if (eq @topic.replyCount 1)}}
                reply
              {{else}}
                replies
              {{/if}}
            </span>
          </div>
        {{/if}}
      </a>
    </article>
  </template>
}

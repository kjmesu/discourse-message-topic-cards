import { apiInitializer } from "discourse/lib/api";
import MessageTopicCard from "../components/message-topic-card";

export default apiInitializer("1.8.0", (api) => {
  api.renderInOutlet(
    "topic-list-before-link",
    <template>
      {{#if @outletArgs.topic.isPrivateMessage}}
        <MessageTopicCard @topic={{@outletArgs.topic}} />
      {{/if}}
    </template>
  );

  api.registerValueTransformer("topic-list-class", ({ value }) => {
    const router = api.container.lookup("service:router");
    const isMessagesPage = router.currentRouteName?.includes("userPrivateMessages");

    if (isMessagesPage) {
      value.push("message-topic-cards-enabled");
    }
    return value;
  });
});

const form = document.querySelector("[data-support-form]");

if (form) {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const data = new FormData(form);
    const topic = data.get("topic") || "Support";
    const email = data.get("email") || "";
    const message = data.get("message") || "";
    const subject = encodeURIComponent(`Within support: ${topic}`);
    const body = encodeURIComponent(
      `Reply email: ${email}\n\nTopic: ${topic}\n\nMessage:\n${message}`
    );
    window.location.href = `mailto:support@withinai.app?subject=${subject}&body=${body}`;
  });
}

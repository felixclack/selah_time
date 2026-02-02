const observer = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.2 }
);

document.querySelectorAll(".reveal").forEach((el, index) => {
  const delay = (index % 6) * 80;
  el.style.transitionDelay = `${delay}ms`;
  observer.observe(el);
});

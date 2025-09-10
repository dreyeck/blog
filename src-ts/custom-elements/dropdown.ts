/**
 * Custom element `<custom-dropdown>` that uses absolute positioning to place
 * itself right below its parent element. Useful as a `popovertarget`.
 */
export const defineDropdownCustomElement = () => {
  customElements.define(
    "custom-dropdown",
    class DropdownElement extends HTMLElement {
      constructor() {
        super();
      }

      observer?: IntersectionObserver;

      connectedCallback() {
        this.reposition();

        this.observer = new IntersectionObserver(() => this.reposition());
        this.observer.observe(this);
      }

      disconnectedCallback() {
        this.observer?.disconnect();
        this.observer = undefined;
      }

      /**
       * Positions the dropdown so that it's right below its parent element.
       */
      reposition() {
        const parentRect = this.parentElement?.getBoundingClientRect();
        const isVisible = this.checkVisibility();

        if (!parentRect || !isVisible) {
          return;
        }

        const selfRect = this.getBoundingClientRect();
        const xParentMiddle = parentRect.left + parentRect.width / 2;
        const viewportRight = document.documentElement.clientWidth;
        const viewportBottom = document.documentElement.clientHeight;
        const maxTop = viewportBottom - selfRect.height;
        const maxLeft = viewportRight - selfRect.width;
        const centeredLeft = xParentMiddle - selfRect.width / 2;

        const top = Math.max(0, Math.min(maxTop, parentRect.bottom));
        const left = Math.max(0, Math.min(maxLeft, centeredLeft));

        this.style = `inset: unset; top: calc(0.5rem + ${top}px); left: ${left}px`;
      }
    },
  );
};

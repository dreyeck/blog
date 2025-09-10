export const defineAudioPlayerCustomElement = () => {
  customElements.define(
    "audio-player",
    class AudioPlayerElement extends HTMLElement {
      constructor() {
        super();
      }

      audioElement?: HTMLAudioElement;
      onTimeUpdate?: (event: Event) => void;

      static get observedAttributes() {
        return ["src", "playing", "current-time"];
      }

      connectedCallback() {
        this.audioElement = new Audio();

        this.onTimeUpdate = (_event) => {
          if (!this.audioElement) {
            return;
          }

          this.dispatchEvent(
            new CustomEvent("timeupdate", {
              detail: {
                playing: !this.audioElement.paused,
                currentTime: this.audioElement.currentTime,
                duration: this.audioElement.duration,
              },
            }),
          );
        };
        this.audioElement.addEventListener("timeupdate", this.onTimeUpdate);

        this.appendChild(this.audioElement);
        this.update();
      }

      attributeChangedCallback() {
        this.update();
      }

      disconnectedCallback() {
        this.audioElement?.pause();
        if (this.onTimeUpdate) {
          this.audioElement?.removeEventListener(
            "timeupdate",
            this.onTimeUpdate,
          );
        }
        this.audioElement = undefined;
      }

      update() {
        if (!this.audioElement) {
          return;
        }

        const src = this.getAttribute("src");
        const playing = this.getAttribute("playing");
        const currentTimeStr = this.getAttribute("current-time");
        const currentTime = currentTimeStr
          ? Number.parseInt(currentTimeStr)
          : null;

        const currentSrc = this.audioElement.getAttribute("src");
        const currentCurrentTime = this.audioElement.currentTime;

        if (src !== null && src !== currentSrc) {
          this.audioElement.setAttribute("src", src);
        }

        if (
          currentTime !== null &&
          Math.abs(currentTime - currentCurrentTime) > 2
        ) {
          this.audioElement.currentTime = currentTime;
        }

        if (playing === "true") {
          this.audioElement.play();
        } else {
          this.audioElement.pause();
        }
      }
    },
  );
};

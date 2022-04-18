import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = "https://www.youtube.com/player_api";
    
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(script, firstScriptTag);

    script.onload = this.initPlayer;
  }

  initPlayer() {
    let player;
    window.YT.ready(function() {
      player = new YT.Player('video', {
        events: {
          'onReady': onPlayerReady,
        }
      });
    });

    function onPlayerReady(event) {
      var playButton = document.getElementById("play-button");
      if (playButton) {
        playButton.addEventListener("click", function() {
          player.playVideo();
        });
      }

      var pauseButton = document.getElementById("pause-button");
      if (pauseButton) {
          pauseButton.addEventListener("click", function() {
              player.pauseVideo();
          });
      }

      var stopButton = document.getElementById("stop-button");
      if (stopButton) {
        stopButton.addEventListener("click", function() {
          player.stopVideo();
        });
      }
    }
  }
}

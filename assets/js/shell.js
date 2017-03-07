import Terminal from "xterm";
import _ from "underscore";
import socket from "./socket";

var channel;
var term;

function connect() {
    channel = socket.channel("sandbox:0", {});
    channel.join()
        .receive("ok", resp => { console.log("Joined successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })
}

function run_cmd() {
    console.log("Command: " + this.command);

    channel.push("run", this.command);

    this.command
    this.command = "";
}

$(function() {
    var page = $('body').data('page');
    if (page != "PageView/shell") {
        return;
    }

    connect();

    var vv = new Vue({
        el: '#shell-vue',
        data: {
            status: "loading...",
            lines: [],
            command: "",
        },
        methods: {
            run_cmd: run_cmd,
        }
    });

    channel.on("chunks", resp => {
        term.reset();
        _.each(resp.chunks, cc => {
            cc = cc.replace(/\n/g, "\r\n");
            term.write(cc);
            /*
            _.each(cc.split(/\r?\n/), ll => {
                term.writeln(ll);
                console.log(ll);
            });
            */
        });
    });

    term = new Terminal({
        cursorBlink: false,
        cols: 100,
        rows: 40,
    });
    term.open($('#xterm')[0]);
    $(function() { term.reset(); });

    window.term = term;
});

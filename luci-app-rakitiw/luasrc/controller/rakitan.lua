module("luci.controller.rakitan", package.seeall)
function index()
entry({"admin","modem","rakitan"}, template("rakitan"), _("Modem Rakitan"), 7).leaf=true
end

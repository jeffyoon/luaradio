local os = require('os')
local io = require('io')
local radio = require('radio')

if #arg < 2 then
    io.stderr:write("Usage: " .. arg[0] .. " <FM baseband IQ f32le recording> <sample rate>\n")
    os.exit(1)
end

local fm_deemph_b_taps = {0.03153663993126178, 0.03153663993126178}
local fm_deemph_a_taps = {1, -0.9369267201374764}

local audio_lpf_taps = {0.00075568569312, 0.000853018327262, 0.000812720732952, 0.000584600746918, 0.000119238175979, -0.000591735599128, -0.00147275697005, -0.0023395095094, -0.00291078523528, -0.00286596690435, -0.00194194965193, -4.71059827451e-05, 0.002642096662, 0.0056392982044, 0.00819038372907, 0.00940955487226, 0.00849350214446, 0.00497189589487, -0.00106616501712, -0.00883499527818, -0.016857667655, -0.0231391774342, -0.0254944730171, -0.0219785537992, -0.0113344642415, 0.00663915466737, 0.0308912188923, 0.0591522012705, 0.0882126591354, 0.114407236411, 0.134218188996, 0.14488265174, 0.14488265174, 0.134218188996, 0.114407236411, 0.0882126591354, 0.0591522012705, 0.0308912188923, 0.00663915466737, -0.0113344642415, -0.0219785537992, -0.0254944730171, -0.0231391774342, -0.016857667655, -0.00883499527818, -0.00106616501712, 0.00497189589487, 0.00849350214446, 0.00940955487226, 0.00819038372907, 0.0056392982044, 0.002642096662, -4.71059827451e-05, -0.00194194965193, -0.00286596690435, -0.00291078523528, -0.0023395095094, -0.00147275697005, -0.000591735599128, 0.000119238175979, 0.000584600746918, 0.000812720732952, 0.000853018327262, 0.00075568569312}

local b0 = radio.FileIQSourceBlock(arg[1], 'f32le', tonumber(arg[2]))
local b1 = radio.FrequencyDiscriminatorBlock(10.0)
local b2 = radio.IIRFilterBlock(fm_deemph_b_taps, fm_deemph_a_taps)
local b3 = radio.FIRFilterBlock(audio_lpf_taps)
local b4 = radio.DownsamplerBlock(4)
local b5 = radio.FileDescriptorSinkBlock(1)
local top = radio.CompositeBlock(true)

top:connect(b0, "out", b1, "in")
top:connect(b1, "out", b2, "in")
top:connect(b2, "out", b3, "in")
top:connect(b3, "out", b4, "in")
top:connect(b4, "out", b5, "in")
top:run()
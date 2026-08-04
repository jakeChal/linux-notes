-  **Check HW and drivers used**
    ```shell
    lspci -k | grep -A3 -i -E "vga|3d"
    ```

    Example output

    ```shell
    00:02.0 VGA compatible controller: Intel Corporation Kaby Lake-R GT2 [UHD Graphics 620] (rev 07)
            Subsystem: Acer Incorporated [ALI] Device 121b
            Kernel driver in use: i915
            Kernel modules: i915
    --
    01:00.0 3D controller: NVIDIA Corporation GP108M [GeForce MX150] (rev a1)
            Subsystem: Acer Incorporated [ALI] Device 121a
            Kernel driver in use: nouveau
            Kernel modules: nvidiafb, nouveau

    ```

    This machine has 2 GPUs: 

    - an integrated one from Intel (low power one for most tasks, like desktop, browsing etc)
        Side note: you can confirm that the Desktop is rendered with this one via `glxinfo -B`.
    - a separate NVIDIA chip (power hungry one for 3D tasks like gaming, rendering etc)

    The NVIDIA one uses the *nouveau* driver - aka the included open-source & reverse engineered driver for NVIDIA chips. It doesn't have CUDA support and doesn't have all NVIDIA features.


- **Installing proprietary NVIDIA drivers (Ubuntu variants)**

    ```shell
    ubuntu-drivers devices
    ```

    Example output

    ```shell
        == /sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0 ==
    modalias : pci:v000010DEd00001D10sv00001025sd0000121Abc03sc02i00
    vendor   : NVIDIA Corporation
    model    : GP108M [GeForce MX150]
    driver   : nvidia-driver-580-server - distro non-free
    driver   : nvidia-driver-580 - distro non-free recommended
    driver   : xserver-xorg-video-nouveau - distro free builtin
    ```

    As we see, there is a recommended (non-free) driver for the NVIDIA GPU. To install it:

    ```shell
    sudo apt update
    sudo ubuntu-drivers install
    ```

    Then reboot, and verify it worked with:

    ```shell
    lspci -k | grep -A3 NVIDIA # should show that the NVIDIA kernel driver is used
    nvidia-smi # NVIDIA interface that shows current usage of the NVIDIA GPU
    ```

    


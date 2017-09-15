pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__ping.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__ping.adb");
pragma Suppress (Overflow_Check);

with System.Restrictions;

package body ada_main is

   E095 : Short_Integer; pragma Import (Ada, E095, "ada__tags_E");
   E053 : Short_Integer; pragma Import (Ada, E053, "system__soft_links_E");
   E051 : Short_Integer; pragma Import (Ada, E051, "system__exception_table_E");
   E109 : Short_Integer; pragma Import (Ada, E109, "system__bb__timing_events_E");
   E189 : Short_Integer; pragma Import (Ada, E189, "ada__streams_E");
   E197 : Short_Integer; pragma Import (Ada, E197, "system__finalization_root_E");
   E195 : Short_Integer; pragma Import (Ada, E195, "ada__finalization_E");
   E199 : Short_Integer; pragma Import (Ada, E199, "system__storage_pools_E");
   E192 : Short_Integer; pragma Import (Ada, E192, "system__finalization_masters_E");
   E414 : Short_Integer; pragma Import (Ada, E414, "system__storage_pools__subpools_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "ada__real_time_E");
   E472 : Short_Integer; pragma Import (Ada, E472, "gnat__secure_hashes_E");
   E474 : Short_Integer; pragma Import (Ada, E474, "gnat__secure_hashes__sha1_E");
   E470 : Short_Integer; pragma Import (Ada, E470, "gnat__sha1_E");
   E404 : Short_Integer; pragma Import (Ada, E404, "ada__strings__maps_E");
   E468 : Short_Integer; pragma Import (Ada, E468, "ada__strings__maps__constants_E");
   E201 : Short_Integer; pragma Import (Ada, E201, "system__pool_global_E");
   E504 : Short_Integer; pragma Import (Ada, E504, "system__pool_size_E");
   E212 : Short_Integer; pragma Import (Ada, E212, "system__tasking__protected_objects_E");
   E232 : Short_Integer; pragma Import (Ada, E232, "system__tasking__protected_objects__multiprocessors_E");
   E226 : Short_Integer; pragma Import (Ada, E226, "system__tasking__restricted__stages_E");
   E165 : Short_Integer; pragma Import (Ada, E165, "aip__nif_E");
   E210 : Short_Integer; pragma Import (Ada, E210, "net__buffers_E");
   E214 : Short_Integer; pragma Import (Ada, E214, "net__interfaces_E");
   E138 : Short_Integer; pragma Import (Ada, E138, "aip__checksum_E");
   E121 : Short_Integer; pragma Import (Ada, E121, "aip__io_E");
   E172 : Short_Integer; pragma Import (Ada, E172, "aip__pcbs_E");
   E127 : Short_Integer; pragma Import (Ada, E127, "aip__time_types_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "aip__timers_E");
   E182 : Short_Integer; pragma Import (Ada, E182, "aip__arp_E");
   E157 : Short_Integer; pragma Import (Ada, E157, "aip__icmp_E");
   E136 : Short_Integer; pragma Import (Ada, E136, "aip__ip_E");
   E167 : Short_Integer; pragma Import (Ada, E167, "aip__tcp_E");
   E174 : Short_Integer; pragma Import (Ada, E174, "aip__udp_E");
   E131 : Short_Integer; pragma Import (Ada, E131, "bmp_fonts_E");
   E296 : Short_Integer; pragma Import (Ada, E296, "cortex_m__cache_E");
   E389 : Short_Integer; pragma Import (Ada, E389, "generic_unbounded_array_E");
   E432 : Short_Integer; pragma Import (Ada, E432, "generic_unbounded_ptr_array_E");
   E283 : Short_Integer; pragma Import (Ada, E283, "hal__audio_E");
   E187 : Short_Integer; pragma Import (Ada, E187, "hal__bitmap_E");
   E348 : Short_Integer; pragma Import (Ada, E348, "bitmap_color_conversion_E");
   E309 : Short_Integer; pragma Import (Ada, E309, "hal__block_drivers_E");
   E261 : Short_Integer; pragma Import (Ada, E261, "hal__dsi_E");
   E381 : Short_Integer; pragma Import (Ada, E381, "hal__filesystem_E");
   E376 : Short_Integer; pragma Import (Ada, E376, "filesystem__fat_E");
   E380 : Short_Integer; pragma Import (Ada, E380, "filesystem__fat__files_E");
   E378 : Short_Integer; pragma Import (Ada, E378, "filesystem__fat__directories_E");
   E373 : Short_Integer; pragma Import (Ada, E373, "file_io_E");
   E383 : Short_Integer; pragma Import (Ada, E383, "filesystem__mbr_E");
   E340 : Short_Integer; pragma Import (Ada, E340, "hal__framebuffer_E");
   E274 : Short_Integer; pragma Import (Ada, E274, "hal__gpio_E");
   E279 : Short_Integer; pragma Import (Ada, E279, "hal__i2c_E");
   E287 : Short_Integer; pragma Import (Ada, E287, "hal__real_time_clock_E");
   E304 : Short_Integer; pragma Import (Ada, E304, "hal__sdmmc_E");
   E313 : Short_Integer; pragma Import (Ada, E313, "hal__spi_E");
   E325 : Short_Integer; pragma Import (Ada, E325, "hal__time_E");
   E362 : Short_Integer; pragma Import (Ada, E362, "hal__touch_panel_E");
   E361 : Short_Integer; pragma Import (Ada, E361, "ft6x06_E");
   E371 : Short_Integer; pragma Import (Ada, E371, "hershey_fonts_E");
   E369 : Short_Integer; pragma Import (Ada, E369, "bitmapped_drawing_E");
   E418 : Short_Integer; pragma Import (Ada, E418, "object_E");
   E420 : Short_Integer; pragma Import (Ada, E420, "object__handle_E");
   E342 : Short_Integer; pragma Import (Ada, E342, "otm8009a_E");
   E324 : Short_Integer; pragma Import (Ada, E324, "ravenscar_time_E");
   E427 : Short_Integer; pragma Import (Ada, E427, "raw_mqtt_dispatcher_E");
   E455 : Short_Integer; pragma Import (Ada, E455, "raw_tcp_dispatcher_E");
   E457 : Short_Integer; pragma Import (Ada, E457, "raw_tcp_echo_E");
   E302 : Short_Integer; pragma Import (Ada, E302, "sdmmc_init_E");
   E350 : Short_Integer; pragma Import (Ada, E350, "soft_drawing_bitmap_E");
   E346 : Short_Integer; pragma Import (Ada, E346, "memory_mapped_bitmap_E");
   E514 : Short_Integer; pragma Import (Ada, E514, "stack_storage_E");
   E241 : Short_Integer; pragma Import (Ada, E241, "stm32__adc_E");
   E244 : Short_Integer; pragma Import (Ada, E244, "stm32__dac_E");
   E250 : Short_Integer; pragma Import (Ada, E250, "stm32__dma__interrupts_E");
   E333 : Short_Integer; pragma Import (Ada, E333, "stm32__dma2d_E");
   E336 : Short_Integer; pragma Import (Ada, E336, "stm32__dma2d__interrupt_E");
   E338 : Short_Integer; pragma Import (Ada, E338, "stm32__dma2d__polling_E");
   E344 : Short_Integer; pragma Import (Ada, E344, "stm32__dma2d_bitmap_E");
   E260 : Short_Integer; pragma Import (Ada, E260, "stm32__dsi_E");
   E270 : Short_Integer; pragma Import (Ada, E270, "stm32__exti_E");
   E356 : Short_Integer; pragma Import (Ada, E356, "stm32__fmc_E");
   E278 : Short_Integer; pragma Import (Ada, E278, "stm32__i2c_E");
   E289 : Short_Integer; pragma Import (Ada, E289, "stm32__power_control_E");
   E266 : Short_Integer; pragma Import (Ada, E266, "stm32__rcc_E");
   E436 : Short_Integer; pragma Import (Ada, E436, "stm32__rng_E");
   E439 : Short_Integer; pragma Import (Ada, E439, "stm32__rng__interrupts_E");
   E434 : Short_Integer; pragma Import (Ada, E434, "net__utils_E");
   E286 : Short_Integer; pragma Import (Ada, E286, "stm32__rtc_E");
   E518 : Short_Integer; pragma Import (Ada, E518, "stm32__calendar_E");
   E312 : Short_Integer; pragma Import (Ada, E312, "stm32__spi_E");
   E315 : Short_Integer; pragma Import (Ada, E315, "stm32__spi__dma_E");
   E264 : Short_Integer; pragma Import (Ada, E264, "stm32__gpio_E");
   E308 : Short_Integer; pragma Import (Ada, E308, "stm32__sdmmc_interrupt_E");
   E282 : Short_Integer; pragma Import (Ada, E282, "stm32__i2s_E");
   E268 : Short_Integer; pragma Import (Ada, E268, "stm32__syscfg_E");
   E293 : Short_Integer; pragma Import (Ada, E293, "stm32__sdmmc_E");
   E237 : Short_Integer; pragma Import (Ada, E237, "stm32__device_E");
   E366 : Short_Integer; pragma Import (Ada, E366, "stm32__eth_E");
   E352 : Short_Integer; pragma Import (Ada, E352, "stm32__ltdc_E");
   E320 : Short_Integer; pragma Import (Ada, E320, "stm32__sai_E");
   E322 : Short_Integer; pragma Import (Ada, E322, "stm32__setup_E");
   E399 : Short_Integer; pragma Import (Ada, E399, "strings_edit_E");
   E479 : Short_Integer; pragma Import (Ada, E479, "strings_edit__base64_E");
   E500 : Short_Integer; pragma Import (Ada, E500, "strings_edit__fields_E");
   E410 : Short_Integer; pragma Import (Ada, E410, "strings_edit__integer_edit_E");
   E391 : Short_Integer; pragma Import (Ada, E391, "raw_lwip_server_E");
   E393 : Short_Integer; pragma Import (Ada, E393, "raw_lwip_server__api_process_E");
   E396 : Short_Integer; pragma Import (Ada, E396, "raw_socket_dispatcher_E");
   E387 : Short_Integer; pragma Import (Ada, E387, "connection_state_machine_E");
   E423 : Short_Integer; pragma Import (Ada, E423, "connection_state_machine__big_endian__unsigneds_E");
   E506 : Short_Integer; pragma Import (Ada, E506, "connection_state_machine__expected_sequence_E");
   E508 : Short_Integer; pragma Import (Ada, E508, "connection_state_machine__terminated_strings_E");
   E494 : Short_Integer; pragma Import (Ada, E494, "strings_edit__float_edit_E");
   E481 : Short_Integer; pragma Import (Ada, E481, "strings_edit__floats_E");
   E480 : Short_Integer; pragma Import (Ada, E480, "strings_edit__floats_E");
   E498 : Short_Integer; pragma Import (Ada, E498, "strings_edit__quoted_E");
   E385 : Short_Integer; pragma Import (Ada, E385, "mqtt_E");
   E425 : Short_Integer; pragma Import (Ada, E425, "mqtt__clients_E");
   E447 : Short_Integer; pragma Import (Ada, E447, "handles_E");
   E520 : Short_Integer; pragma Import (Ada, E520, "tables_E");
   E522 : Short_Integer; pragma Import (Ada, E522, "tables__names_E");
   E516 : Short_Integer; pragma Import (Ada, E516, "strings_edit__time_conversions_E");
   E465 : Short_Integer; pragma Import (Ada, E465, "connection_state_machine__http_server_E");
   E463 : Short_Integer; pragma Import (Ada, E463, "test_http_servers_E");
   E451 : Short_Integer; pragma Import (Ada, E451, "test_mqtt_clients_E");
   E327 : Short_Integer; pragma Import (Ada, E327, "wm8994_E");
   E235 : Short_Integer; pragma Import (Ada, E235, "audio_E");
   E359 : Short_Integer; pragma Import (Ada, E359, "touch_panel_ft6x06_E");
   E354 : Short_Integer; pragma Import (Ada, E354, "sdcard_E");
   E217 : Short_Integer; pragma Import (Ada, E217, "stm32__sdram_E");
   E331 : Short_Integer; pragma Import (Ada, E331, "framebuffer_dsi_E");
   E329 : Short_Integer; pragma Import (Ada, E329, "framebuffer_otm8009a_E");
   E219 : Short_Integer; pragma Import (Ada, E219, "stm32__board_E");
   E364 : Short_Integer; pragma Import (Ada, E364, "net__interfaces__stm32_E");
   E180 : Short_Integer; pragma Import (Ada, E180, "aip__osal_E");
   E205 : Short_Integer; pragma Import (Ada, E205, "net__minif_E");
   E445 : Short_Integer; pragma Import (Ada, E445, "aip__osal__single_E");
   E459 : Short_Integer; pragma Import (Ada, E459, "receiver_E");
   E134 : Short_Integer; pragma Import (Ada, E134, "demos_E");
   E441 : Short_Integer; pragma Import (Ada, E441, "os_service_E");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");
      procedure Install_Restricted_Handlers_Sequential;
      pragma Import (C,Install_Restricted_Handlers_Sequential, "__gnat_attach_all_handlers");

      Partition_Elaboration_Policy : Character;
      pragma Import (C, Partition_Elaboration_Policy, "__gnat_partition_elaboration_policy");

      procedure Activate_All_Tasks_Sequential;
      pragma Import (C, Activate_All_Tasks_Sequential, "__gnat_activate_all_tasks");
      procedure Start_Slave_CPUs;
      pragma Import (C, Start_Slave_CPUs, "__gnat_start_slave_cpus");
   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := 0;
      WC_Encoding := 'b';
      Locking_Policy := 'C';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := 'F';
      Partition_Elaboration_Policy := 'S';
      System.Restrictions.Run_Time_Restrictions :=
        (Set =>
          (False, True, False, False, False, False, True, False, 
           False, False, False, False, False, False, True, True, 
           False, False, False, False, False, True, False, False, 
           False, False, False, False, False, False, False, True, 
           True, False, False, True, True, False, False, False, 
           True, False, False, False, False, True, False, True, 
           True, False, False, False, False, True, True, True, 
           True, True, False, True, False, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, True, False, False, True, 
           False, False, False, False, False, True, True, False, 
           True, False, False),
         Value => (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
         Violated =>
          (False, False, False, True, True, True, False, False, 
           False, False, True, True, True, True, False, False, 
           False, False, False, True, True, False, True, True, 
           False, True, True, True, True, False, True, False, 
           False, False, True, False, False, True, False, True, 
           False, True, True, False, True, False, True, False, 
           False, False, True, False, True, False, False, False, 
           False, False, True, False, True, True, True, False, 
           False, True, False, True, True, True, False, True, 
           True, False, True, True, True, True, False, False, 
           True, False, False, False, True, False, False, True, 
           False, True, False),
         Count => (0, 0, 0, 1, 0, 0, 3, 0, 10, 0),
         Unknown => (False, False, False, False, False, False, False, False, True, False));
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 1;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      Runtime_Initialize (1);

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E051 := E051 + 1;
      Ada.Tags'Elab_Body;
      E095 := E095 + 1;
      System.Bb.Timing_Events'Elab_Spec;
      E109 := E109 + 1;
      E053 := E053 + 1;
      Ada.Streams'Elab_Spec;
      E189 := E189 + 1;
      System.Finalization_Root'Elab_Spec;
      E197 := E197 + 1;
      Ada.Finalization'Elab_Spec;
      E195 := E195 + 1;
      System.Storage_Pools'Elab_Spec;
      E199 := E199 + 1;
      System.Finalization_Masters'Elab_Spec;
      System.Finalization_Masters'Elab_Body;
      E192 := E192 + 1;
      System.Storage_Pools.Subpools'Elab_Spec;
      E414 := E414 + 1;
      Ada.Real_Time'Elab_Body;
      E006 := E006 + 1;
      E472 := E472 + 1;
      E474 := E474 + 1;
      Gnat.Sha1'Elab_Spec;
      E470 := E470 + 1;
      Ada.Strings.Maps'Elab_Spec;
      E404 := E404 + 1;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E468 := E468 + 1;
      System.Pool_Global'Elab_Spec;
      E201 := E201 + 1;
      System.Pool_Size'Elab_Spec;
      E504 := E504 + 1;
      System.Tasking.Protected_Objects'Elab_Body;
      E212 := E212 + 1;
      System.Tasking.Protected_Objects.Multiprocessors'Elab_Body;
      E232 := E232 + 1;
      System.Tasking.Restricted.Stages'Elab_Body;
      E226 := E226 + 1;
      AIP.NIF'ELAB_BODY;
      E165 := E165 + 1;
      Net.Buffers'Elab_Spec;
      Net.Buffers'Elab_Body;
      E210 := E210 + 1;
      Net.Interfaces'Elab_Spec;
      Net.Interfaces'Elab_Body;
      E214 := E214 + 1;
      E138 := E138 + 1;
      E121 := E121 + 1;
      E172 := E172 + 1;
      AIP.TIME_TYPES'ELAB_BODY;
      E127 := E127 + 1;
      AIP.TIMERS'ELAB_BODY;
      E129 := E129 + 1;
      E182 := E182 + 1;
      E157 := E157 + 1;
      E136 := E136 + 1;
      AIP.TCP'ELAB_BODY;
      E167 := E167 + 1;
      E174 := E174 + 1;
      E131 := E131 + 1;
      Cortex_M.Cache'Elab_Body;
      E296 := E296 + 1;
      E389 := E389 + 1;
      E432 := E432 + 1;
      HAL.AUDIO'ELAB_SPEC;
      E283 := E283 + 1;
      HAL.BITMAP'ELAB_SPEC;
      E187 := E187 + 1;
      E348 := E348 + 1;
      HAL.BLOCK_DRIVERS'ELAB_SPEC;
      E309 := E309 + 1;
      HAL.DSI'ELAB_SPEC;
      E261 := E261 + 1;
      HAL.FILESYSTEM'ELAB_SPEC;
      E381 := E381 + 1;
      Filesystem.Fat'Elab_Spec;
      E378 := E378 + 1;
      E380 := E380 + 1;
      Filesystem.Fat'Elab_Body;
      E376 := E376 + 1;
      FILE_IO'ELAB_BODY;
      E373 := E373 + 1;
      E383 := E383 + 1;
      HAL.FRAMEBUFFER'ELAB_SPEC;
      E340 := E340 + 1;
      HAL.GPIO'ELAB_SPEC;
      E274 := E274 + 1;
      HAL.I2C'ELAB_SPEC;
      E279 := E279 + 1;
      HAL.REAL_TIME_CLOCK'ELAB_SPEC;
      E287 := E287 + 1;
      HAL.SDMMC'ELAB_SPEC;
      E304 := E304 + 1;
      HAL.SPI'ELAB_SPEC;
      E313 := E313 + 1;
      HAL.TIME'ELAB_SPEC;
      E325 := E325 + 1;
      HAL.TOUCH_PANEL'ELAB_SPEC;
      E362 := E362 + 1;
      Ft6x06'Elab_Spec;
      Ft6x06'Elab_Body;
      E361 := E361 + 1;
      E371 := E371 + 1;
      E369 := E369 + 1;
      Object'Elab_Spec;
      Object'Elab_Body;
      E418 := E418 + 1;
      E420 := E420 + 1;
      OTM8009A'ELAB_SPEC;
      OTM8009A'ELAB_BODY;
      E342 := E342 + 1;
      Ravenscar_Time'Elab_Spec;
      Ravenscar_Time'Elab_Body;
      E324 := E324 + 1;
      E427 := E427 + 1;
      E455 := E455 + 1;
      E457 := E457 + 1;
      E302 := E302 + 1;
      Soft_Drawing_Bitmap'Elab_Spec;
      Soft_Drawing_Bitmap'Elab_Body;
      E350 := E350 + 1;
      Memory_Mapped_Bitmap'Elab_Spec;
      Memory_Mapped_Bitmap'Elab_Body;
      E346 := E346 + 1;
      Stack_Storage'Elab_Spec;
      Stack_Storage'Elab_Body;
      E514 := E514 + 1;
      STM32.ADC'ELAB_SPEC;
      E241 := E241 + 1;
      E244 := E244 + 1;
      E250 := E250 + 1;
      E333 := E333 + 1;
      STM32.DMA2D.INTERRUPT'ELAB_BODY;
      E336 := E336 + 1;
      E338 := E338 + 1;
      STM32.DMA2D_BITMAP'ELAB_SPEC;
      STM32.DMA2D_BITMAP'ELAB_BODY;
      E344 := E344 + 1;
      STM32.DSI'ELAB_SPEC;
      STM32.DSI'ELAB_BODY;
      E260 := E260 + 1;
      E270 := E270 + 1;
      E356 := E356 + 1;
      STM32.I2C'ELAB_SPEC;
      STM32.I2C'ELAB_BODY;
      E278 := E278 + 1;
      E289 := E289 + 1;
      E266 := E266 + 1;
      E436 := E436 + 1;
      STM32.RNG.INTERRUPTS'ELAB_BODY;
      E439 := E439 + 1;
      E434 := E434 + 1;
      STM32.RTC'ELAB_SPEC;
      STM32.RTC'ELAB_BODY;
      E286 := E286 + 1;
      E518 := E518 + 1;
      STM32.SPI'ELAB_SPEC;
      STM32.SPI'ELAB_BODY;
      E312 := E312 + 1;
      STM32.SPI.DMA'ELAB_SPEC;
      STM32.SPI.DMA'ELAB_BODY;
      E315 := E315 + 1;
      STM32.GPIO'ELAB_SPEC;
      STM32.I2S'ELAB_SPEC;
      STM32.GPIO'ELAB_BODY;
      E264 := E264 + 1;
      STM32.SDMMC'ELAB_SPEC;
      E308 := E308 + 1;
      STM32.DEVICE'ELAB_SPEC;
      E237 := E237 + 1;
      STM32.SDMMC'ELAB_BODY;
      E293 := E293 + 1;
      STM32.I2S'ELAB_BODY;
      E282 := E282 + 1;
      E268 := E268 + 1;
      E366 := E366 + 1;
      STM32.LTDC'ELAB_BODY;
      E352 := E352 + 1;
      E320 := E320 + 1;
      E322 := E322 + 1;
      Strings_Edit'Elab_Spec;
      E399 := E399 + 1;
      E479 := E479 + 1;
      E500 := E500 + 1;
      E410 := E410 + 1;
      Raw_Lwip_Server'Elab_Spec;
      Raw_Lwip_Server'Elab_Body;
      E391 := E391 + 1;
      E393 := E393 + 1;
      E396 := E396 + 1;
      Connection_State_Machine'Elab_Spec;
      Connection_State_Machine'Elab_Body;
      E387 := E387 + 1;
      Connection_State_Machine.Big_Endian.Unsigneds'Elab_Spec;
      Connection_State_Machine.Big_Endian.Unsigneds'Elab_Body;
      E423 := E423 + 1;
      Connection_State_Machine.Expected_Sequence'Elab_Spec;
      Connection_State_Machine.Expected_Sequence'Elab_Body;
      E506 := E506 + 1;
      Connection_State_Machine.Terminated_Strings'Elab_Spec;
      Connection_State_Machine.Terminated_Strings'Elab_Body;
      E508 := E508 + 1;
      E494 := E494 + 1;
      Strings_Edit.Floats'Elab_Body;
      E481 := E481 + 1;
      E498 := E498 + 1;
      MQTT'ELAB_SPEC;
      MQTT'ELAB_BODY;
      E385 := E385 + 1;
      E425 := E425 + 1;
      Handles'Elab_Spec;
      E447 := E447 + 1;
      E520 := E520 + 1;
      E522 := E522 + 1;
      Strings_Edit.Time_Conversions'Elab_Spec;
      Strings_Edit.Time_Conversions'Elab_Body;
      E516 := E516 + 1;
      Connection_State_Machine.Http_Server'Elab_Spec;
      Connection_State_Machine.Http_Server'Elab_Body;
      E465 := E465 + 1;
      Test_Http_Servers'Elab_Spec;
      Test_Http_Servers'Elab_Body;
      E463 := E463 + 1;
      Test_Mqtt_Clients'Elab_Spec;
      Test_Mqtt_Clients'Elab_Body;
      E451 := E451 + 1;
      WM8994'ELAB_SPEC;
      WM8994'ELAB_BODY;
      E327 := E327 + 1;
      Audio'Elab_Spec;
      Touch_Panel_Ft6x06'Elab_Spec;
      Sdcard'Elab_Spec;
      Framebuffer_Dsi'Elab_Spec;
      Framebuffer_Otm8009a'Elab_Spec;
      Framebuffer_Otm8009a'Elab_Body;
      E329 := E329 + 1;
      STM32.BOARD'ELAB_SPEC;
      E219 := E219 + 1;
      Touch_Panel_Ft6x06'Elab_Body;
      E359 := E359 + 1;
      Sdcard'Elab_Body;
      E354 := E354 + 1;
      Audio'Elab_Body;
      E235 := E235 + 1;
      E217 := E217 + 1;
      Framebuffer_Dsi'Elab_Body;
      E331 := E331 + 1;
      Net.Interfaces.Stm32'Elab_Spec;
      Net.Interfaces.Stm32'Elab_Body;
      E364 := E364 + 1;
      AIP.OSAL'ELAB_SPEC;
      E180 := E180 + 1;
      E205 := E205 + 1;
      E445 := E445 + 1;
      Receiver'Elab_Spec;
      Receiver'Elab_Body;
      E459 := E459 + 1;
      Os_Service'Elab_Spec;
      E134 := E134 + 1;
      Os_Service'Elab_Body;
      E441 := E441 + 1;
      Install_Restricted_Handlers_Sequential;
      Activate_All_Tasks_Sequential;
      Start_Slave_CPUs;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_ping");

   procedure main is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
   end;

--  BEGIN Object file/option list
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/bmp_fonts.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/hershey_fonts.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/bitmapped_drawing.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/test_http_servers.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/test_mqtt_clients.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/receiver.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/demos.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/os_service.o
   --   /home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/ping.o
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/obj/stm32f769disco/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/examples/shared/common/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/boards/stm32f769_discovery/lib/ravenscar-sfp-stm32f769disco/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/arch/ARM/STM32/lib/stm32f7x9/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/hal/lib/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/middleware/lib/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/arch/ARM/cortex_m/lib/cortex-m7/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/Ada_Drivers_Library/components/lib/
   --   -L/home/mhanuel/Devel/ADA/projects/ada-ipstack/lib/stm32f769disco/ravenscar-sfp/
   --   -L/usr/local/gnat/arm-eabi/lib/gnat/ravenscar-full-stm32f769disco/adalib/
--  END Object file/option list   

end ada_main;

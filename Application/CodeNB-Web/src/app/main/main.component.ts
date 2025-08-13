import {
  Component,
  ElementRef,
  OnInit,
  Renderer2,
  ViewChild,
} from '@angular/core';
import { RouterOutlet } from '@angular/router';
import {
  faBars,
} from '@fortawesome/free-solid-svg-icons';
import { SideBarComponent } from '@shared/side-bar/side-bar.component';
import { CollapseModule } from 'ngx-bootstrap/collapse';
import { FontAwesomeModule } from '@fortawesome/angular-fontawesome';

@Component({
  selector: 'app-main',
  imports: [SideBarComponent, RouterOutlet, CollapseModule, FontAwesomeModule],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss',
  standalone: true,
})
export class MainComponent implements OnInit {
  @ViewChild('isSideNavShow') isSideNavShow: ElementRef;
  isCollapsed = true;
  icon = faBars;

  constructor(private renderer: Renderer2) {}

  ngOnInit(): void {}

  toggleSideNav() {
    this.isCollapsed = !this.isCollapsed;
    this.renderer.removeClass(
      this.isSideNavShow.nativeElement,
      this.isCollapsed ? 'g-sidenav-pinned' : 'g-sidenav-hidden'
    );
    this.renderer.addClass(
      this.isSideNavShow.nativeElement,
      this.isCollapsed ? 'g-sidenav-hidden' : 'g-sidenav-pinned'
    );
  }
}
